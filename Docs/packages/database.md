# Base de Datos — IA DataFlow

Esquema MySQL v3.9. Gestiona usuarios, proyectos, AI jobs, ETL, notificaciones y auditoría.  
Ubicación: `packages/database/`

---

## Estructura

```
packages/database/
├── schema.prisma                        ← Fuente de verdad (Prisma v3.9)
├── migrations/
│   ├── migration_lock.toml
│   └── 20240101000000_init_v3/
│       └── migration.sql
└── IA-Dataflow Database V1/             ← Histórico de referencia
```

---

## Requisitos

`.env` en la raíz del proyecto:

```env
DB_PASSWORD=tu_password
DB_NAME=ia_dataflow
DATABASE_URL=mysql://root:${DB_PASSWORD}@localhost:3307/${DB_NAME}
```

---

## Docker

```bash
# Primer inicio — aplica el esquema automáticamente
docker compose up db -d

# Verificar que esté listo
docker compose logs db --tail=50

# phpMyAdmin en http://localhost:8080
docker compose up db phpmyadmin -d

# Reiniciar desde cero (destruye datos)
docker compose down -v && docker compose up db -d
```

---

## Prisma

```bash
# Marcar migración inicial como aplicada (solo una vez)
npx prisma migrate resolve --applied 20240101000000_init_v3

# Generar cliente
npx prisma generate

# Ver estado
npx prisma migrate status

# Nueva migración
npx prisma migrate dev --name nombre_del_cambio

# Producción / CI
npx prisma migrate deploy
```

---

## Notas del esquema v3.9

- Todas las queries filtran `WHERE deleted_at IS NULL`.
- `tokens_total` en `ai_jobs` se calcula en la app (no es columna generada).
- Campos ENUM migrados a `VARCHAR` para consistencia con Prisma.

| HU | Descripción |
|----|-------------|
| HU-016 | ENUMs → tablas de catálogo |
| HU-017 | Auditoría completa + soft-delete |
| HU-018 | Multi-proveedor de autenticación |
| HU-019 | Configuración flexible clave-valor |
| HU-020 | Roles por equipo, proyecto y grupo |
| HU-021 | Proyectos auditados + relaciones archivos ↔ conversaciones |
| HU-022 | Tracking AI jobs (lifecycle, métricas, costos, reintentos) |
| HU-023 | Feedback y reportes |
| HU-024 | Sesiones y dispositivos |
| HU-025 | Notificaciones con tracking de entrega |
| HU-026 | Datasets con lineage |
| HU-027 | Templates ETL y ejecuciones |


---

## Documentos relacionados

**Arquitectura:** [[ARQUITECTURA]] · [[DOCUMENTACION_TECNICA]]
**Diagramas:** [[03-modelo-base-de-datos]]
**Apps:** [[api]]
**HUs:** [[✅ HU 011 - Diseño y Creación de la Base de Datos Relacional (MySQL)|HU-011]] · [[✅ HU 012 - Implementación del Esquema con Prisma ORM|HU-012]] · [[✅ HU 030 - Migración Estratégica de IDs Enteros a UUID|HU-030]] · [[HU 071 - Eliminar Todos los ENUMs y Migrar a Catálogos|HU-071]]
