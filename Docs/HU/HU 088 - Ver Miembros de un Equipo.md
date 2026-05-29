# HU 088 - Ver Miembros de un Equipo

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-084

---

## HU-088: Ver miembros de un equipo

**Como** miembro de un equipo,
**quiero** ver la lista de miembros del equipo seleccionado,
**para** saber quiénes colaboran conmigo.

### Criterios de Aceptación
- El sistema debe llamar a `GET /teams/:id/members` al seleccionar o abrir la vista de un equipo
- El sistema debe mostrar nombre, email y rol de cada miembro
- El sistema debe distinguir visualmente al propietario (Owner) del resto de miembros
- El sistema debe mostrar un spinner durante la carga

### Notas
- Depende de HU-084
