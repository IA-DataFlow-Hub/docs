# API — IA-DataFlow-Hub

Backend construido con **NestJS + Prisma + MySQL 8**.  
Ubicación: `apps/api/`

---

## Requisitos

- Node.js 18+
- Docker Desktop (para la base de datos)
- Archivo `.env` en la raíz del proyecto

---

## Comandos

```bash
# Desarrollo con hot-reload
npm run dev

# Compilar para producción
npm run build

# Ejecutar en producción
npm run start:prod
```

## Tests

```bash
npm run test        # unit
npm run test:e2e    # e2e
npm run test:cov    # cobertura
```

---

## Arquitectura — Clean Architecture

Cada módulo sigue la estructura:

```
apps/api/src/modules/<módulo>/
├── <módulo>.module.ts
├── domain/
│   ├── entities/
│   └── repositories/
├── application/
│   ├── dtos/
│   ├── use-cases/
│   └── facades/
└── infrastructure/
    ├── controllers/
    └── persistence/
        └── mappers/
```

---

## Módulos

| HU | Módulo | Tablas principales |
|----|--------|--------------------|
| HU-040 | Auth y Sesiones | `users`, `credentials`, `sessions` |
| HU-041 | Perfil y Configuración | `users`, `user_configurations` |
| HU-042 | Teams y RBAC | `teams`, `team_roles`, `permissions` |
| HU-043 | Proyectos y Fases | `projects`, `project_phases` |
| HU-044 | Archivos y Versionado | `files`, `file_versions` |
| HU-045 | Conversaciones | `conversations`, `messages` |
| HU-046 | Tareas | `tasks` |
| HU-047 | Motor de IA (AI Jobs) | `ai_jobs`, `ai_job_events`, `ai_results` |
| HU-048 | ETL y Tablas Generadas | `generated_tables`, `etl_executions` |
| HU-049 | Feedback y Reportes | `message_feedback`, `reports` |
| HU-050 | Notificaciones | `notifications`, `notification_groups` |
| HU-051 | Auditoría | `audit_logs`, `audits` |
