# Reglas de seguridad

1. `DELETE` sin `WHERE` es `CRITICAL`.
2. `UPDATE` sin `WHERE` es `CRITICAL`.
3. Las clausulas `WHERE` que sean tautologias, como `1 = 1`, `TRUE` o `col = col`, son `CRITICAL`.
4. `DROP`, `TRUNCATE` y operaciones destructivas de `ALTER TABLE` son `CRITICAL`.
5. El SQL dinamico construido con concatenacion de cadenas o interpolacion desde valores no confiables es `HIGH`.
6. Si el texto SQL expone un limite obvio de inyeccion, nombra ese limite en el hallazgo.
7. Si la consulta depende de permisos, politicas por fila o restricciones que no fueron proporcionadas, reporta la incertidumbre como `INFO`.
