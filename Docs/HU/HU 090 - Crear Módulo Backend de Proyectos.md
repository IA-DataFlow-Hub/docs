# HU 090 - Crear Módulo Backend de Proyectos

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)

---

## HU-090: Crear módulo backend de Proyectos (CRUD)

**Como** desarrollador backend,
**quiero** un módulo NestJS de Proyectos con endpoints CRUD en `/projects`,
**para** que el frontend pueda persistir proyectos en la base de datos en lugar de manejarlos solo en memoria local.

### Criterios de Aceptación
- El sistema debe exponer `POST /projects` — crear proyecto (`name`, `description`, `color`)
- El sistema debe exponer `GET /projects` — listar proyectos del usuario autenticado
- El sistema debe exponer `GET /projects/:id` — obtener proyecto por ID
- El sistema debe exponer `PATCH /projects/:id` — actualizar nombre, descripción y color
- El sistema debe exponer `DELETE /projects/:id` — eliminar proyecto
- El sistema debe asociar cada proyecto al `userId` del token JWT
- El sistema debe seguir Clean Architecture igual que los módulos existentes (`domain/application/infrastructure`)
- El sistema debe documentar los endpoints en Swagger

### Notas
- Prerequisito para HU-091, HU-092, HU-093
- Los endpoints de `conversations`, `tasks` y `ai-jobs` ya reciben `projectId` como parámetro de ruta — este módulo provee la entidad base
