# HU 098 - Avanzar Fase del Proyecto desde el Frontend

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-097

---

## HU-098: Avanzar fase del proyecto desde el frontend

**Como** usuario autenticado,
**quiero** poder avanzar mi proyecto a la siguiente fase del ciclo BPM con un botón desde el Dashboard,
**para** mover el proyecto de DISEÑAR → EJECUTAR → SUPERVISAR → OPTIMIZAR conforme se completa cada etapa.

### Criterios de Aceptación
- El sistema debe mostrar un botón "Avanzar Fase" (o similar) visible cuando el proyecto no está en su fase final ni archivado
- El sistema debe llamar a `POST /projects/:id/advance-phase` al confirmar la acción
- El sistema debe mostrar un diálogo de confirmación antes de avanzar ("¿Avanzar de DISEÑAR a EJECUTAR?")
- El sistema debe actualizar el indicador de fase activa en el Dashboard inmediatamente tras respuesta exitosa
- El sistema debe deshabilitar el botón si el proyecto está en la última fase o archivado
- El sistema debe mostrar error si la API retorna 404 o cualquier error inesperado

### Notas
- El cambio de fase actualiza `currentPhase` en el `ProjectResponseDto` — actualizar el proyecto en el contexto local
- Depende de HU-097 (catálogo y visualización de fases)
