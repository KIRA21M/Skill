# Reporte de la Fase Red Team

## Datos de evaluacion

- Equipo evaluador: Samuel Jonathan Trujillo Bolanos (KIRA21M) y Diana Laura Olmos Antonio (Yilin_roux).
- Equipo evaluado: Maria Jose Linares Cortes.
- Repositorio evaluado: https://github.com/marijolinares/skill.git
- Fecha de evaluacion: 2026-08-11.

## Objetivo

Evaluar si la skill `sql-reviewer` del repositorio objetivo mantiene un comportamiento seguro, claro y reproducible frente a entradas SQL que pueden pasar una revision superficial, pero que presentan riesgos de seguridad, correctitud o consistencia.

## Metodologia

Se revisaron `SKILL.md`, las reglas de seguridad, rendimiento y convenciones, los ejemplos y las pruebas disponibles en el repositorio objetivo. Se usaron entradas SQL adversariales y se comparo el resultado esperado contra las reglas escritas por el equipo evaluado.

La revision fue estatica: las sentencias se trataron como entradas para la skill y no se ejecutaron contra una base de datos. No se asumieron esquema, cardinalidad, indices, dialecto ni reglas de negocio que no estuvieran documentados.

## Hallazgos

### RT-01 - Severidad no determinista para SQL dinamico

- Severidad: HIGH.
- Entrada probada:

```sql
EXECUTE IMMEDIATE 'DELETE FROM users WHERE id = ' || :user_id;
```

- Evidencia: `rules/security.md` indica que el SQL dinamico construido con concatenacion puede ser `HIGH` o `CRITICAL`, segun que tan directamente pueda abusarse. `SKILL.md` exige clasificar cada hallazgo con un solo nivel y mantener resultados reproducibles.
- Riesgo: dos revisiones de la misma entrada pueden producir severidades distintas. Ademas, la sentencia combina SQL dinamico y una operacion destructiva, pero la regla no establece una precedencia exacta entre ambos riesgos.
- Recomendacion: definir una matriz fija: `CRITICAL` para SQL dinamico no parametrizado que genere DML o DDL destructivo o una tautologia; `HIGH` para SQL dinamico no destructivo con entrada no confiable; y una nota `INFO` solo cuando no sea posible confirmar el origen del valor.

### RT-02 - Clasificacion ambigua de filtros amplios en DML

- Severidad: MEDIUM.
- Entrada probada:

```sql
UPDATE accounts
SET status = 'disabled'
WHERE email IS NOT NULL;
```

- Evidencia: `rules/security.md` indica que un filtro que pueda tocar la mayoria de las filas debe tratarse como riesgo de cambio masivo, pero no define una severidad ni un criterio observable para decidirlo. `SKILL.md` tambien prohibe inventar cardinalidad o cantidad de filas.
- Riesgo: sin conocer los datos, una revision puede marcar la sentencia como `HIGH`, `CRITICAL` o no marcarla. La salida deja de ser reproducible y el revisor puede convertir una posibilidad contextual en una afirmacion.
- Recomendacion: separar el criterio sintactico del contextual. Si el predicado es una tautologia o una coincidencia total demostrable, usar `CRITICAL`. Si solo es potencialmente amplio y faltan datos de cardinalidad, reportar `INFO` con la incertidumbre. Si el equipo quiere una alerta preventiva para todo DML amplio, fijar una severidad unica y documentarla.

### RT-03 - Cobertura incompleta de la semantica de NULL en NOT IN

- Severidad: MEDIUM.
- Entrada probada:

```sql
SELECT id
FROM users
WHERE id NOT IN (SELECT user_id FROM blocked_users);
```

- Evidencia: `rules/conventions.md` cubre comparaciones directas como `= NULL` y `<> NULL`, y menciona `COALESCE`, `IFNULL` y `NVL`, pero no define una regla para `NOT IN` cuando la subconsulta puede devolver `NULL`.
- Riesgo: si la subconsulta contiene un `NULL`, la logica ternaria de SQL puede impedir que las filas esperadas pasen el filtro. La skill puede no advertirlo ni indicar que falta confirmar la nulabilidad de `blocked_users.user_id`.
- Recomendacion: agregar una regla explicita para `NOT IN` con subconsultas. Si la nulabilidad no esta documentada, emitir `INFO` y solicitar ese dato. Si se confirma que la columna acepta `NULL`, recomendar `NOT EXISTS` o un filtro explicito de nulos, sin afirmar que el cambio es universal para todos los dialectos.

## Resultado de la evaluacion

La skill evaluada detecta correctamente varios riesgos basicos: operaciones de escritura sin `WHERE`, tautologias, SQL dinamico concatenado, coincidencias totales, limites excesivos y problemas de rendimiento comunes. Los huecos encontrados no consisten en ignorar todos esos patrones, sino en la falta de criterios completamente deterministas para algunos casos y en una cobertura parcial de la semantica de `NULL`.

## Trazabilidad de la evidencia

- RT-01 se contrasto con `SKILL.md` y `rules/security.md`, en las secciones de procedimiento, validacion y SQL dinamico.
- RT-02 se contrasto con `SKILL.md` y `rules/security.md`, en las reglas sobre filtros amplios y en la prohibicion de inventar cardinalidad.
- RT-03 se contrasto con `rules/conventions.md`, en las reglas de `NULL`, y con la ausencia de un caso equivalente en las pruebas del repositorio.
- Los tres casos se revisaron sin asumir un motor especifico ni datos que no estuvieran incluidos en las entradas.

## Conclusion

El resultado es: **requiere ajustes menores antes de considerarse completamente reproducible**.

Las correcciones prioritarias son fijar una severidad unica para cada combinacion de SQL dinamico y operacion destructiva, documentar como clasificar filtros amplios cuando falta cardinalidad y agregar una prueba especifica para `NOT IN` con posibles valores `NULL`.
