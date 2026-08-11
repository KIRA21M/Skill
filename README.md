# Skill SQL Reviewer

Este repositorio contiene una skill reutilizable `sql-reviewer` para revisar sentencias y scripts SQL.

## Contenido
- `SKILL.md` define activacion, procedimiento, reglas, niveles de severidad y manejo de fallas.
- `rules/security.md` contiene validaciones orientadas a seguridad.
- `rules/performance.md` contiene validaciones orientadas a rendimiento.
- `rules/conventions.md` contiene validaciones de nomenclatura y legibilidad.
- `examples/` contiene ejemplos de entrada SQL.
- `tests/` contiene cinco casos de validacion basados en escenarios.

## Alcance
El repositorio se mantiene enfocado en los requisitos de la actividad:
- Revisar SQL.
- Clasificar hallazgos con los niveles de severidad requeridos.
- Evitar inventar contexto de esquema o de carga de trabajo.
- Proporcionar comportamiento determinista y manejo explicito de casos alternos.

## Notas
La skill esta pensada para ser reproducible y facil de defender oralmente:
- Las reglas estan escritas como decisiones concretas.
- Los datos faltantes se manejan de forma explicita.
- Los hallazgos se vinculan con evidencia SQL concreta.
