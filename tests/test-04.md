# Test 04

## Input
```sql
SELECT
  customer_id,
  SUM(total_amount)
FROM orders
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY customer_id;
```

## Expected behavior
La skill debe evitar afirmar que falta un indice porque no se proporcionaron metadatos del esquema.

## Actual behavior
La revision mantiene la observacion en nivel `INFO` y dice que la presencia del indice no se puede confirmar solo con la entrada.

## Pass / Fail
Aprobado

## Problem detected
No se deben inventar conclusiones que dependan del esquema.

## Modification made to the skill
Se agrego una salida explicita en `INFO` cuando faltan metadatos del esquema o de indices.
