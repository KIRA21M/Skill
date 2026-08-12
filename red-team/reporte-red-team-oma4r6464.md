# Reporte de la Fase Red Team

## Datos de evaluación

- Equipo evaluador: Yilin_roux (Diana Laura Olmos Antonio y Samuel Jonathan Trujillo Bolaños, KIRA21M).
- Equipo evaluado: Kevin Omar Sixto Lázaro y Arian Pablo Rosales.
- Repositorio evaluado: https://github.com/oma4r6464/sql-reviewer-skill.git
- Fecha de evaluación: 2026-08-11.

## Objetivo

Evaluar si la skill `sql-reviewer` del repositorio evaluado mantiene un comportamiento seguro,
determinista y reproducible frente a entradas SQL que cumplen superficialmente sus reglas
documentadas pero siguen siendo riesgosas o incorrectas.

## Metodología

Se revisaron `SKILL.md` y las reglas en `rules/security.md`, `rules/performance.md` y
`rules/conventions.md` (formato `SR-xxx`, `PR-xxx`, `CV-xxx`). Se diseñaron entradas SQL
adversariales dirigidas específicamente a los heurísticos sintácticos declarados en esas reglas,
y se contrastó cada entrada contra el texto exacto de la regla aplicable. La revisión fue
estática: no se ejecutó SQL contra una base de datos real, ni se asumió esquema, cardinalidad,
motor o reglas de negocio no documentados por el equipo evaluado.

## Hallazgos

### RT-01 — El heurístico de "columna única" en SR-007 se evade con una llave foránea

- Severidad: HIGH.
- Entrada probada:

```sql
DELETE FROM orders WHERE customer_id = 42;
```

- Evidencia: `rules/security.md`, regla SR-007, exige que la columna del `WHERE` **no** termine
  en `id`/`_id` para clasificar el hallazgo como `HIGH` ("heurístico: nombre de columna no
  termina en _id/id"). `customer_id` es una llave foránea, no una clave única, por lo que un
  `DELETE` filtrado por esa columna puede borrar múltiples filas (todos los pedidos de ese
  cliente) sin que ninguna regla lo señale.
- Riesgo: el heurístico usa el *nombre* de la columna como proxy de unicidad real, algo que el
  texto SQL no puede confirmar por sí solo. Una sentencia destructiva con impacto potencialmente
  amplio queda sin ningún hallazgo.
- Recomendación: separar el criterio de "columna con sufijo `_id`" del criterio real de
  unicidad. Sin metadatos de esquema, tratar toda columna no confirmada como `UNIQUE`/`PRIMARY KEY`
  de forma explícita (vía input opcional) como no-única por defecto, y degradar a `INFO` solo la
  parte que dependa de esa confirmación — no omitir el hallazgo completo.

### RT-02 — Sin cobertura para `NOT IN` con subconsulta nullable

- Severidad: MEDIUM.
- Entrada probada:

```sql
SELECT id_user
FROM users
WHERE id_user NOT IN (SELECT user_id FROM blocked_users);
```

- Evidencia: `rules/conventions.md`, CV-003, solo cubre comparaciones directas `= NULL` /
  `!= NULL` / `<> NULL`. No existe una regla `CV-xxx` para `NOT IN` con subconsulta.
- Riesgo: si `blocked_users.user_id` admite `NULL`, la lógica ternaria de SQL hace que la
  consulta no devuelva ninguna fila, aunque existan usuarios legítimamente no bloqueados. Es un
  bug funcional silencioso equivalente en severidad a CV-003, y actualmente no se reporta ni
  siquiera como `INFO`.
- Recomendación: agregar una regla explícita para `NOT IN` con subconsulta. Si la nulabilidad de
  la columna de la subconsulta no fue confirmada por el usuario, emitir `INFO` señalando el
  riesgo y pidiendo ese dato; si se confirma que admite `NULL`, recomendar `NOT EXISTS` o un
  filtro explícito de nulos.

### RT-03 — La escalación a HIGH en PR-002 depende de `SELECT *`, no del volumen de filas

- Severidad: MEDIUM.
- Entrada probada:

```sql
SELECT o.id_order, o.total_amount
FROM orders o
JOIN customers c ON o.id_customer = c.id_customer;
```

- Evidencia: `rules/performance.md`, PR-002, condiciona la escalación a `HIGH` a que la consulta
  *también* dispare PR-001 (`SELECT *`) y tenga `JOIN`. Con columnas explícitas pero sin `WHERE`
  selectivo ni `LIMIT`, la sentencia se queda en `MEDIUM`.
- Riesgo: el riesgo real de un `JOIN` sin `WHERE`/`LIMIT` es el número de filas devueltas, no el
  ancho de las columnas seleccionadas. Limitar columnas no acota el cruce completo entre dos
  tablas potencialmente grandes.
- Recomendación: desacoplar la escalación a `HIGH` de PR-001. Un `JOIN` sin predicado selectivo
  ni `LIMIT` debería escalar a `HIGH` independientemente de si las columnas están explícitas o
  no; `SELECT *` puede seguir sumando severidad de forma independiente (o quedar como una
  agravante adicional documentada, no como condición necesaria).

## Resultado de la evaluación

La skill evaluada detecta correctamente las violaciones estructurales básicas exigidas por la
actividad: escrituras sin `WHERE`, tautologías (incluida la variante `LIKE '%'`), SQL dinámico
concatenado, límites inefectivos y varios problemas de tipos/rendimiento. Los tres huecos
encontrados comparten un mismo patrón: usan una señal sintáctica superficial (sufijo del nombre
de columna, presencia de `*`, ausencia de `NULL` comparado directamente) como proxy de un riesgo
que en realidad depende de una propiedad no verificable desde el texto SQL (unicidad real,
nulabilidad real, volumen real de filas) — exactamente el tipo de evasión que la actividad pide
exponer en esta fase.

## Trazabilidad de la evidencia

- RT-01 se contrastó con `rules/security.md`, regla SR-007.
- RT-02 se contrastó con `rules/conventions.md`, reglas CV-003/CV-004, y con la ausencia de una
  regla equivalente para `NOT IN`.
- RT-03 se contrastó con `rules/performance.md`, regla PR-002 y su bloque de `ESCALATION`.
- Los tres casos se revisaron sin asumir un motor específico ni datos de esquema no incluidos en
  las entradas.

## Conclusión

El resultado es: **requiere ajustes menores antes de considerarse completamente reproducible**.

Las correcciones prioritarias son independizar SR-007 del sufijo del nombre de columna, agregar
una regla explícita para `NOT IN` con subconsultas nullable, y desacoplar la escalación a `HIGH`
de PR-002 de la presencia de `SELECT *`.

Hallazgo reportado al equipo de Kevin Omar Sixto Lázaro y Arian Pablo Rosales el 2026-08-11.
