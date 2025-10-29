@echo off
echo ======================================
echo COMMIT: Nuevas tareas T131, T132, T133
echo ======================================

echo.
echo Añadiendo cambios al staging...
git add docs/tareas/TASKS.md

echo.
echo Creando commit...
git commit -m "feat: Añadir nuevas tareas T131-T133

- T131: Sincronización con calendarios externos (Google Calendar, Outlook)
- T132: Definición sistema de agencias de viajes
- T133: Exportación profesional de planes a PDF/Email

Actualizado contador: 107 tareas (57 completadas, 50 pendientes)
Siguiente código: T134"

echo.
echo Haciendo push...
git push

echo.
echo ¡Commit y push completados!
pause



