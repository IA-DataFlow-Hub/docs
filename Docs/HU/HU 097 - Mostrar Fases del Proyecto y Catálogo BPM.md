# HU 097 - Mostrar Fases del Proyecto y Catálogo BPM

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-092

---

## HU-097: Mostrar fases del proyecto y catálogo BPM en el frontend

**Como** usuario autenticado,
**quiero** ver en qué fase del flujo BPM se encuentra mi proyecto y cuáles son las fases disponibles,
**para** entender el estado del ciclo DISEÑAR → EJECUTAR → SUPERVISAR → OPTIMIZAR y el historial de fases completadas.

### Criterios de Aceptación
- El sistema debe llamar a `GET /projects/phases/catalog` una sola vez al cargar el Dashboard y cachear el resultado en contexto global
- El sistema debe mostrar las 4 fases del ciclo BPM (DISEÑAR, EJECUTAR, SUPERVISAR, OPTIMIZAR) con su orden y descripción
- El sistema debe resaltar visualmente la fase activa del proyecto seleccionado (`currentPhase`)
- El sistema debe llamar a `GET /projects/:id/phases` al seleccionar un proyecto y mostrar el historial de fases con fecha de inicio y fin de cada una
- El sistema debe mostrar un indicador de progreso del proyecto basado en la fase actual vs total de fases

### Notas
- El Dashboard ya tiene un selector de fase (`currentPhase`) hardcodeado — reemplazar con datos reales del proyecto
- La barra de fases BPM está en `Dashboard.tsx` como selector `DISEÑAR | EJECUTAR | SUPERVISAR | OPTIMIZAR`
- Depende de HU-092 (proyectos cargados desde API)
