# SQL Reviewer

## Purpose
Revisar sentencias y scripts SQL como un revisor tecnico determinista.
La skill debe identificar problemas de correccion, seguridad, rendimiento y nomenclatura sin ejecutar SQL ni inventar contexto faltante.

## When to activate
Activala cuando la entrada contenga sentencias SQL, scripts SQL, procedimientos almacenados, fragmentos de migracion de base de datos, fragmentos de consulta o SQL incrustado que necesite revision tecnica.

## When NOT to activate
No la actives cuando:
- La entrada no sea SQL y no tenga SQL incrustado.
- El usuario pida ejecutar, correr o medir una consulta en vez de revisarla.
- La solicitud requiera esquema, conteo de filas, indices o reglas de negocio que no fueron proporcionados y no puedan inferirse con seguridad.
- El usuario quiera una leccion generica de SQL en lugar de una revision del texto SQL especifico.

## Inputs
La skill acepta:
- Una o mas sentencias o scripts SQL.
- Informacion opcional del dialecto, como PostgreSQL, MySQL, SQL Server, SQLite o ANSI SQL.
- Metadatos opcionales del esquema, de indices y de cardinalidad de tablas.
- Reglas de negocio, politicas de seguridad o metas de rendimiento opcionales.

Si faltan detalles del dialecto, del esquema o de la carga de trabajo, la skill no debe inventarlos.

## Procedure
1. Divide la entrada en sentencias y clasifica cada una por tipo.
2. Normaliza cambios superficiales de formato sin alterar el significado.
3. Revisa primero riesgos de seguridad, luego correccion, despues rendimiento y al final convenciones.
4. Aplica las reglas explicitas de este archivo y de `rules/*.md`.
5. Si una regla depende de informacion faltante del esquema o de la carga de trabajo, reporta la incertidumbre en lugar de adivinar.
6. Ordena los hallazgos de mayor a menor severidad.
7. Si no hay hallazgos, indica que el SQL es aceptable bajo el contexto proporcionado.

## Rules
La skill debe usar reglas de decision explicitas.

SI statement = DELETE
Y WHERE esta ausente
ENTONCES severity = CRITICAL
Y no recomiendes ejecutar la sentencia.

SI statement = UPDATE
Y WHERE esta ausente
ENTONCES severity = CRITICAL
Y no recomiendes ejecutar la sentencia.

SI hay una clausula WHERE
Y el predicado es una tautologia como `1 = 1`, `TRUE`, `col = col` u otro filtro siempre verdadero
ENTONCES severity = CRITICAL
Y trata la sentencia como efectivamente ilimitada.

SI la sentencia contiene operaciones destructivas como `DROP`, `TRUNCATE`, `ALTER TABLE ... DROP` o acciones equivalentes de perdida de datos
ENTONCES severity = CRITICAL.

SI el texto SQL muestra concatenacion o interpolacion de cadenas que pueda inyectar valores no confiables en SQL
ENTONCES severity = HIGH
Y menciona el limite de inyeccion de forma explicita.

SI `NULL` se compara con `=`, `!=` o `<>` en lugar de `IS NULL` o `IS NOT NULL`
ENTONCES severity = HIGH
Y explica el error de comparacion con null.

SI una sentencia DDL guarda un valor claramente numerico, monetario o de fecha en un tipo de texto sin justificacion en la entrada
ENTONCES severity = MEDIUM
Y explica la incompatibilidad de tipos.

SI un predicado coincide con todas las filas mediante logica comodin como `LIKE '%'` o `ILIKE '%'`
ENTONCES trata la sentencia como efectivamente ilimitada
Y aplica `CRITICAL` a DML destructivo o `HIGH` a consultas de solo lectura.

SI `LIMIT` es extremadamente grande, por ejemplo `1000000` o mas
ENTONCES severity = HIGH
Y explica que el tope no es realmente restrictivo.

SI el problema depende de hechos del esquema que no fueron proporcionados
ENTONCES severity = INFO
Y indica que la conclusion no se puede confirmar.

SI varias reglas coinciden
ENTONCES usa la severidad mas alta que aplique.

## Severity levels
- CRITICAL: Riesgo inmediato de comportamiento destructivo o inseguro.
- HIGH: Riesgo fuerte de seguridad, correccion o rendimiento que debe corregirse antes de usarlo.
- MEDIUM: Problema importante de mantenibilidad o eficiencia con impacto moderado.
- LOW: Problema de estilo, nombres o claridad con riesgo directo limitado.
- INFO: Problema incierto, contexto faltante o nota de caracter informativo que no puede confirmarse.

## Expected output
La skill debe producir:
- Una evaluacion general breve.
- Una lista de hallazgos, cada uno con:
  - Severidad
  - Sentencia o fragmento
  - Evidencia
  - Por que importa
  - Correccion recomendada

Si el contexto es insuficiente, la salida debe decir que falta y que no se puede concluir.
La skill nunca debe afirmar con certeza que existen indices, conteos de filas o restricciones cuando esos datos no fueron proporcionados.

## Validation
Antes de finalizar una revision, verifica que:
- Cada hallazgo apunte a texto SQL concreto.
- Ningun hallazgo dependa de esquema o carga de trabajo inventados.
- La severidad coincida con las reglas explicitas.
- Las recomendaciones no le digan al usuario que ejecute SQL inseguro.
- La revision siga siendo reproducible cuando se entregue la misma entrada otra vez.

## Failure handling
Si la entrada es ambigua, analiza cada posible limite de sentencia y explica donde esta la ambiguedad.
Si el dialecto es desconocido, usa supuestos conservadores de ANSI SQL y anota la incertidumbre especifica del dialecto.
Si faltan datos del esquema, degrada a `INFO` las conclusiones que dependan de ese esquema.
Si la entrada esta mal formada, reporta el problema de parseo y revisa solo las partes que sigan siendo legibles.
Si el contenido no es SQL, explica que la skill no se activa para esa entrada.
