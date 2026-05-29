# HU 107 - Pruebas de Caja Negra — Validación Manual de Endpoints vía Swagger

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Alta
> **Depende de:** HU-106

---

## HU-107: Pruebas de caja negra — validación manual de todos los endpoints vía Swagger

**Como** responsable de calidad del proyecto,
**quiero** abrir el Swagger UI y probar manualmente cada endpoint de todos los módulos del API,
**para** verificar que las entradas y salidas corresponden al contrato documentado, sin conocer el código interno.

### Criterios de Aceptación

#### Preparación
- El sistema debe levantar el entorno con `docker-compose up` y verificar que el API responde en `http://localhost:3001/api/docs`
- El sistema debe obtener un token JWT válido via `POST /auth/login` con un usuario de prueba (seed)
- El sistema debe autenticar Swagger con el token (botón "Authorize")

#### Módulos a probar (todos los endpoints)

| Módulo | Endpoints | Estado esperado |
|--------|-----------|-----------------|
| Auth | login, register, refresh, logout, change-password, sessions | 201/200/401 según caso |
| Users | GET/PATCH /users/me, configuraciones | 200/400 |
| Teams | CRUD equipos, miembros, roles, permisos | 201/200/403/404 |
| Projects | CRUD proyectos, fases, avanzar fase, archivar, roles | 201/200/404 |
| Tasks | CRUD tareas, cambiar estado, asignar | 201/200/422/404 |
| Notifications | inbox, marcar leída, eliminar, grupos | 200/204/404 |
| Conversations | CRUD conversaciones, mensajes | 201/200/404 |
| AI Jobs | trigger, listar, detalle, eventos, resultados, cancelar | 201/200/400/404 |
| Audit | audit-logs con filtros, snapshots, revertir | 200/403/404 (solo admin) |
| ETL | templates, datasets, transformaciones | 200/201/400 |
| Files | upload, versiones, soft-delete | 201/200/404 |
| Feedback | crear, listar | 201/200 |
| LLM Gateway | chat/completions, models | 200/400/502 |

#### Por cada endpoint probar
1. **Happy path**: datos válidos → respuesta esperada con esquema correcto
2. **Sin autenticación**: omitir token → debe retornar 401
3. **Datos inválidos**: campos requeridos vacíos o tipo incorrecto → debe retornar 400 con detalle
4. **Recurso inexistente**: ID que no existe → debe retornar 404

#### Documentar resultados
- Crear `docs/QA/reporte-caja-negra.md` con tabla: Endpoint | Método | Escenario | Resultado obtenido | Resultado esperado | ¿Pasa? | Observaciones
- Marcar en rojo cualquier endpoint que no responda según el contrato Swagger
- Registrar discrepancias entre el body documentado en Swagger y la respuesta real

### Entregables
- `docs/QA/reporte-caja-negra.md` con resultados de todos los endpoints
- Lista de bugs encontrados como issues en GitHub con label `bug` y `qa`

### Notas
- Swagger UI disponible en `http://localhost:3001/api/docs` cuando corre el entorno Docker
- El módulo `audit` requiere usuario con `role: admin` — usar el seed de admin
- El módulo `llm-gateway` requiere LM Studio corriendo en `http://localhost:1234`
