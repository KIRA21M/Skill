# SQL Reviewer Skill

This repository contains a reusable `sql-reviewer` skill for reviewing SQL statements and scripts.

## Contents
- `SKILL.md` defines activation, procedure, rules, severity levels, and failure handling.
- `rules/security.md` captures security-oriented checks.
- `rules/performance.md` captures performance-oriented checks.
- `rules/conventions.md` captures naming and readability checks.
- `examples/` contains sample SQL inputs.
- `tests/` contains five scenario-based validation cases.

## Scope
The repository stays focused on the assignment requirements:
- Review SQL.
- Classify findings with the required severity levels.
- Avoid inventing schema or workload context.
- Provide deterministic behavior and explicit fallback handling.

## Notes
The skill is designed to be reproducible and easy to defend orally:
- Rules are written as decision statements.
- Missing data is handled explicitly.
- Findings are tied to concrete SQL evidence.
