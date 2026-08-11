# Test 03

## Input
```sql
DELETE FROM users WHERE 1 = 1;
```

## Expected behavior
The skill should treat the tautological predicate as effectively unbounded and classify the statement as `CRITICAL`.

## Actual behavior
The review flags the statement as `CRITICAL` and explains that `WHERE 1 = 1` does not make the deletion safe.

## Pass / Fail
Pass

## Problem detected
A superficial `WHERE` clause can hide a destructive statement.

## Modification made to the skill
Clarified that tautological predicates such as `1 = 1`, `TRUE`, and `col = col` are `CRITICAL`.
