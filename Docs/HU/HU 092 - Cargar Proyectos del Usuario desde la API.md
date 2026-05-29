# HU 092 - Cargar Proyectos del Usuario desde la API

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-090

---

## HU-092: Cargar proyectos del usuario desde la API al iniciar sesión

**Como** usuario autenticado,
**quiero** que al entrar al Dashboard se carguen mis proyectos reales desde la API,
**para** ver siempre el estado actualizado de mis proyectos en lugar del proyecto de ejemplo hardcodeado.

### Criterios de Aceptación
- El sistema debe llamar a `GET /projects` al montar el `ProjectProvider` o al cargar el Dashboard
- El sistema debe reemplazar el proyecto de ejemplo hardcodeado ("Mi Primer Proyecto") por los proyectos reales del usuario
- El sistema debe seleccionar el último proyecto activo (guardado en localStorage) o el primer proyecto de la lista como proyecto activo por defecto
- El sistema debe mostrar un estado vacío con CTA "Crear tu primer proyecto" si el usuario no tiene proyectos
- El sistema debe mostrar un spinner mientras carga

### Notas
- Actualmente `ProjectContext.tsx` inicializa con un proyecto hardcodeado en `useEffect` — reemplazar esa lógica
- Depende de HU-090
