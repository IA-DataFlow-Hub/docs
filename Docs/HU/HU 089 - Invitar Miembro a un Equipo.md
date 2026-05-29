# HU 089 - Invitar Miembro a un Equipo

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-088

---

## HU-089: Invitar miembro a un equipo

**Como** propietario o administrador de un equipo,
**quiero** poder invitar a un usuario existente a mi equipo ingresando su email,
**para** colaborar con otros usuarios de la plataforma.

### Criterios de Aceptación
- El sistema debe mostrar un input de email con botón "Invitar" en la vista de miembros del equipo
- El sistema debe llamar a `POST /teams/:id/members` con `{ email }` (o `userId` según contrato de la API)
- El sistema debe agregar el nuevo miembro a la lista local tras respuesta exitosa
- El sistema debe mostrar error si el email no corresponde a un usuario registrado (404)
- El sistema debe mostrar error si el usuario ya es miembro del equipo (409)

### Notas
- Depende de HU-088
