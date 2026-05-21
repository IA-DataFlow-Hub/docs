# HU-051 — Módulo de Auditoría

## Asignación de Tablas

`audit_logs` · `audits`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Auditoría siguiendo Clean Architecture,  
**Para** registrar automáticamente todas las acciones críticas del sistema en `audit_logs` (con el diff de valores old/new), mantener un historial reversible de cambios en `audits` (con snapshot JSON), y exponer endpoints de consulta para que administradores auditen la actividad de la plataforma.

**Dependencia:** Requiere HU-040 (Auth) para el `id_user` del contexto JWT. Es consumido como servicio transversal por todos los demás módulos.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/audit/
├── audit.module.ts
├── domain/
│   ├── entities/
│   │   ├── audit-log.entity.ts
│   │   └── audit.entity.ts
│   └── repositories/
│       ├── audit-log.repository.interface.ts
│       └── audit.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-audit-log.dto.ts
│   │   ├── create-audit-snapshot.dto.ts
│   │   ├── audit-log-response.dto.ts
│   │   └── audit-response.dto.ts
│   ├── use-cases/
│   │   ├── log-action.use-case.ts
│   │   ├── snapshot-change.use-case.ts
│   │   ├── revert-change.use-case.ts
│   │   └── query-audit-logs.use-case.ts
│   └── facades/
│       └── audit.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── audit.controller.ts
    └── persistence/
        ├── prisma-audit-log.repository.ts
        ├── prisma-audit.repository.ts
        └── mappers/
            ├── audit-log.mapper.ts
            └── audit.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Registro de acción con diff old/new

**Dado** que cualquier módulo invoca `AuditFacade.logAction(dto)` tras una operación crítica  
**Cuando** `LogActionUseCase` ejecuta  
**Entonces:**
- Persiste en `audit_logs` con:
  - `action`: verbo descriptivo en formato `ENTITY:OPERATION` (ej. `PROJECT:ARCHIVED`, `USER:PASSWORD_CHANGED`).
  - `entity_type` y `entity_id`: identifican el registro afectado.
  - `old_value` y `new_value`: valores como JSON serializado (campos que cambiaron, no el registro completo).
  - `ip_address`: extraída del contexto de request (puede ser `null` si es llamada interna).
  - `id_user`: `null` si es una acción del sistema (migración, seed, job).
- La operación es **no-bloqueante**: un fallo al insertar el log **nunca aborta** la transacción del módulo llamante.
- No expone endpoint HTTP; es exclusivamente invocada vía `AuditFacade`.

### Escenario 2 — Snapshot JSON de cambio reversible

**Dado** que una entidad crítica (proyectos, roles, plantillas ETL) es modificada  
**Cuando** `SnapshotChangeUseCase` recibe `CreateAuditSnapshotDto` con `table_name`, `table_id`, `action`, `data_old` y `data_new`  
**Entonces:**
- Persiste en `audits` con `reverted = false` y `reverted_at = null`.
- `data_old` y `data_new` se almacenan como JSON completo del registro (no solo el diff), permitiendo restauración total.
- `user_id` registra quién realizó el cambio; puede ser `null` para operaciones automáticas.
- El campo `action` acepta: `INSERT`, `UPDATE`, `DELETE`.

### Escenario 3 — Reversión de cambio auditado

**Dado** que un administrador solicita revertir un `id_audit`  
**Cuando** `RevertChangeUseCase` ejecuta  
**Entonces:**
- Localiza el registro en `audits` con `reverted = false`.
- Si `action = 'UPDATE'`: aplica `data_old` como estado actual de la fila en la tabla correspondiente usando Prisma dinámico.
- Si `action = 'DELETE'`: recrea el registro desde `data_old` (si la tabla soporta re-inserción).
- Si `action = 'INSERT'`: elimina el registro creado (soft-delete si aplica).
- Actualiza `reverted = true` y `reverted_at = now()` en `audits`.
- Lanza `AuditAlreadyRevertedException` si `reverted = true`.
- Registra un nuevo `AuditLog` con `action = 'AUDIT:REVERTED'` para trazabilidad de la reversión.

### Escenario 4 — Consulta de logs con filtros compuestos

**Dado** que un administrador consulta `GET /audit-logs?id_user=5&entity_type=PROJECT&from=2024-01-01&to=2024-12-31`  
**Cuando** `QueryAuditLogsUseCase` ejecuta  
**Entonces:**
- Aplica todos los filtros recibidos como condiciones AND con `WHERE deleted_at IS NULL`.
- Soporta filtros: `id_user`, `id_project`, `entity_type`, `entity_id`, `action` (LIKE), `from` / `to` (rango de `created_at`).
- Retorna paginación estándar (`page`, `limit`) ordenada por `created_at DESC`.
- Solo usuarios con rol administrador pueden acceder; lanza `ForbiddenException` para roles inferiores.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/audit-logs` | Listar logs de acción (admin only) |
| GET | `/audit-logs/:id` | Detalle de un log |
| GET | `/audits` | Listar snapshots auditados (admin only) |
| GET | `/audits/:id` | Detalle de snapshot con data_old y data_new |
| POST | `/audits/:id/revert` | Revertir cambio auditado |

---

## Notas Técnicas

- `AuditFacade` exporta dos métodos públicos para uso transversal:
  - `logAction(dto: CreateAuditLogDto): Promise<void>` — fire-and-forget, nunca lanza excepciones al llamante.
  - `snapshotChange(dto: CreateAuditSnapshotDto): Promise<void>` — también fire-and-forget.
- Las tablas de auditoría son append-only en la práctica: el soft-delete (`deleted_at`) de `audit_logs` solo está disponible para administradores en casos de limpieza de datos personales (GDPR).
- `RevertChangeUseCase` usa `prisma[tableName].update()` con el modelo dinámico; el repositorio recibe el `table_name` como string y lo mapea al modelo Prisma correspondiente mediante un diccionario estático. Solo tablas en la lista blanca son reversibles.
- `audits` almacena snapshots JSON completos; `audit_logs` almacena diffs legibles. Ambas tablas coexisten: `audit_logs` es para monitoreo rápido, `audits` es para reversión transaccional.
