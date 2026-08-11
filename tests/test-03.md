# Test 03

## Input
```sql
DELETE FROM users WHERE 1 = 1;
```

## Expected behavior
La skill debe tratar el predicado tautologico como efectivamente ilimitado y clasificar la sentencia como `CRITICAL`.

## Actual behavior
La revision marca la sentencia como `CRITICAL` y explica que `WHERE 1 = 1` no vuelve segura la eliminacion.

## Pass / Fail
Aprobado

## Problem detected
Una clausula `WHERE` superficial puede ocultar una sentencia destructiva.

## Modification made to the skill
Se aclaro que los predicados tautologicos como `1 = 1`, `TRUE` y `col = col` son `CRITICAL`.
