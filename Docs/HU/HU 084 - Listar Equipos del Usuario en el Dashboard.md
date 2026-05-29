# HU 084 - Listar Equipos del Usuario en el Dashboard

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-076

---

## HU-084: Listar equipos del usuario en el Dashboard

**Como** usuario autenticado,
**quiero** ver la lista de equipos a los que pertenezco en el Dashboard,
**para** poder seleccionar con qué equipo estoy trabajando actualmente.

### Criterios de Aceptación
- El sistema debe llamar a `GET /teams` al cargar el Dashboard
- El sistema debe mostrar la lista de equipos en la sección o sidebar correspondiente
- El sistema debe mostrar nombre, descripción y rol del usuario en cada equipo
- El sistema debe mostrar un estado vacío si el usuario no pertenece a ningún equipo
- El sistema debe mostrar un spinner durante la carga y un mensaje de error si la petición falla

### Notas
- `Teams.tsx` es actualmente la página de "nuestro equipo" de la landing — no confundir con la gestión de equipos del dashboard
- Depende de HU-075, HU-076
