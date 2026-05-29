# HU 091 - Conectar "Crear Proyecto" del ProjectManager con la API

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-080, HU-090

---

## HU-091: Conectar "Crear proyecto" del ProjectManager con la API

**Como** usuario autenticado,
**quiero** que al crear un proyecto en el `ProjectManager` se llame a `POST /projects` y se persista en la base de datos,
**para** que mis proyectos no se pierdan al recargar la página.

### Criterios de Aceptación
- El sistema debe llamar a `POST /projects` con `{ name, description, color }` al hacer clic en "Crear" en el `ProjectManager`
- El sistema debe reemplazar el `id` generado localmente con el `id` real devuelto por la API
- El sistema debe mostrar el nuevo proyecto inmediatamente en la lista tras respuesta exitosa
- El sistema debe mostrar el error de validación si `name` está vacío (ya validado en cliente) o hay conflicto en servidor
- El sistema debe mostrar indicador de carga en el botón "Crear" durante la petición

### Notas
- `handleCreateProject` en `ProjectManager.tsx` actualmente usa `createProject()` del contexto local — reemplazar para llamar a la API primero
- Depende de HU-075, HU-080, HU-090
