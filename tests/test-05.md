# Test 05

## Input
```sql
DECLARE @sql NVARCHAR(MAX) =
  'DELETE FROM ' + @tableName + ' WHERE id = ' + CAST(@id AS NVARCHAR(20));

EXEC(@sql);

SELECT *
FROM audit_log
LIMIT 1000000000;
```

## Expected behavior
La skill debe marcar la concatenacion de SQL dinamico como `HIGH`, identificar el limite de inyeccion y marcar el `LIMIT` enorme como sospechosamente debil para una consulta de lectura.

## Actual behavior
La revision marca la concatenacion como `HIGH`, senala el limite no confiable y marca el `LIMIT` enorme como `HIGH`.

## Pass / Fail
Aprobado

## Problem detected
El SQL dinamico puede ocultar la tabla destino destructiva y el valor del identificador inyectado, y un `LIMIT` enorme todavia puede ser efectivamente ilimitado.

## Modification made to the skill
Se agregaron reglas explicitas para concatenacion de cadenas, predicados comodin que abarcan todo, comparaciones con `NULL`, incompatibilidades de tipos y valores de `LIMIT` extremadamente grandes.
