# Reglas de rendimiento

1. `SELECT *` es al menos `MEDIUM` porque solicita columnas innecesarias.
2. Un `SELECT` sin limite, paginacion u otra restriccion clara es `HIGH` cuando la consulta parece destinada a uso repetido o de aplicacion.
3. Las funciones aplicadas sobre columnas filtradas pueden bloquear el uso de indices y deben marcarse como `MEDIUM`, salvo que el contexto indique un riesgo mayor.
4. Los `JOIN` sin un predicado visible de union son `HIGH`.
5. Un indice posiblemente faltante debe reportarse como `INFO` cuando no haya metadatos del esquema.
6. Si una consulta devuelve muchas filas de manera intencional, la skill debe evitar fingir que existe un problema de rendimiento garantizado.
