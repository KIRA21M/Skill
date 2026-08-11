# Test 01

## Input
```sql
SELECT
  u.user_id,
  u.email,
  u.created_at
FROM users AS u
WHERE u.is_active = 1
ORDER BY u.created_at DESC
LIMIT 20;
```

## Expected behavior
La skill no debe reportar hallazgos de seguridad, correccion ni rendimiento para el contexto proporcionado.

## Actual behavior
La revision no devuelve hallazgos y no inventa detalles faltantes del esquema.

## Pass / Fail
Aprobado

## Problem detected
Ninguno.

## Modification made to the skill
Ninguna.
