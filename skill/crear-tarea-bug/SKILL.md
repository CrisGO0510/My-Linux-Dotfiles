---
name: crear-tarea-bug
description: Use when the user finished a bug and asks to create its task in Azure DevOps — e.g. "crea la tarea del bug 557432", "ya terminé el bug 557432", "/crear-tarea-bug". Crea la tarea hija de 1 hora y cerrada.
---

# Crear tarea de un bug (Linktic)

Crea la tarea de desarrollo de 1 hora, cerrada, colgada del bug.

1. Ejecuta `~/Documents/linktic/utilities/hour-reporter/scripts/create-bug-task.sh <bug-id>` y muestra la URL de la tarea. Si el id viene como URL del work item, usa el número final.
2. Si el usuario dice qué corrigió, pásalo con `--description "<texto>"`. Si no, el script usa el título del último PR de front (`core_web_*`) enlazado hacia `develop`.
3. Si aborta por tarea existente, muestra el id y pregunta antes de repetir con `--force`.
4. Si sale con ADVERTENCIA, muestra la URL y lo pendiente; no vuelvas a ejecutar, porque duplicaría.
