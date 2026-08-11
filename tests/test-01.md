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
The skill should report no security, correctness, or performance findings for the provided context.

## Actual behavior
The review returns no findings and does not invent missing schema details.

## Pass / Fail
Pass

## Problem detected
None.

## Modification made to the skill
None.
