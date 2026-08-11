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
The skill should avoid claiming that an index is missing because no schema metadata was provided.

## Actual behavior
The review keeps the note at `INFO` level and states that index presence cannot be confirmed from the input alone.

## Pass / Fail
Pass

## Problem detected
Schema-dependent conclusions must not be invented.

## Modification made to the skill
Added an explicit `INFO` fallback when schema or index metadata is missing.
