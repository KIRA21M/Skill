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
The skill should flag dynamic SQL concatenation as `HIGH`, identify the injection boundary, and flag the huge `LIMIT` as suspiciously weak for a read query.

## Actual behavior
The review marks the concatenation as `HIGH`, points out the untrusted boundary, and flags the huge `LIMIT` as `HIGH`.

## Pass / Fail
Pass

## Problem detected
Dynamic SQL can hide the destructive target table and the injected identifier value, and a huge `LIMIT` can still be effectively unbounded.

## Modification made to the skill
Added explicit rules for string concatenation, wildcard-all predicates, null comparisons, data-type mismatches, and extremely large `LIMIT` values.
