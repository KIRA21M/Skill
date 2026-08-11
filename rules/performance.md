# Performance Rules

1. `SELECT *` is at least `MEDIUM` because it requests unnecessary columns.
2. An unbounded `SELECT` without `LIMIT`, paging, or another clear restriction is `HIGH` when the query appears intended for repeated or application use.
3. Functions wrapped around filtered columns can block index usage and should be flagged as `MEDIUM` unless the surrounding context shows a stronger risk.
4. Joins without a visible join predicate are `HIGH`.
5. A suspected missing index must be reported as `INFO` when schema metadata is absent.
6. If a query returns many rows intentionally, the skill should avoid pretending that a performance issue is guaranteed.
