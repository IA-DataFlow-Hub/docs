# HU-037 — Capa de Servicios del Frontend (Integración con API)

## Historia de Usuario

**Como** equipo de desarrollo del frontend,  
**Quiero** tener una capa de servicios centralizada que conecte el prototipo React con el API real,  
**Para** que los componentes existentes puedan funcionar con datos reales sin reescribir su lógica visual.

---

## Contexto

El prototipo tiene todas las pantallas diseñadas (Login, Dashboard, ProjectManager, FileUpload, etc.) pero ninguna hace llamadas reales al backend. Esta HU crea la capa de servicios que los conecta, de forma que los componentes no necesiten saber cómo funciona el API.

**No depende de que el backend esté completo:** se trabaja con un mock del API (MSW o datos locales) y se reemplaza con el real cuando el backend esté listo.

---

## Criterios de Aceptación

- [ ] Instancia de Axios configurada con `baseURL`, interceptors de token y manejo de errores.
- [ ] Los tokens JWT se guardan de forma segura y se adjuntan automáticamente a cada petición.
- [ ] Si el `access_token` expira, se refresca automáticamente sin que el usuario lo note.
- [ ] Si el refresh también falla, se redirige al login.
- [ ] Cada módulo tiene su propio servicio (authService, projectsService, filesService, etc.).
- [ ] Los tipos TypeScript de los servicios coinciden con `packages/shared-types`.
- [ ] Existe un mock del API para desarrollar sin backend real.
- [ ] Todos los errores del API se muestran al usuario con mensajes claros (usando el `NotificationContext` existente).

---

## Estructura de Archivos

```
apps/client/src/
├── services/
│   ├── api.ts              ← instancia base de Axios
│   ├── auth.service.ts
│   ├── projects.service.ts
│   ├── files.service.ts
│   ├── aiJobs.service.ts
│   ├── datasets.service.ts
│   ├── reports.service.ts
│   ├── teams.service.ts
│   └── notifications.service.ts
├── hooks/
│   ├── useAuth.ts          ← estado de autenticación global
│   ├── useProjects.ts
│   ├── useFiles.ts
│   └── useNotifications.ts
└── test/
    └── mocks/
        └── handlers.ts     ← mock del API con MSW
```

---

## Configuración de Axios

```typescript
// services/api.ts

// Lógica a implementar (sin código):
// - baseURL desde variable de entorno VITE_API_URL
// - interceptor de request: adjunta Authorization: Bearer <token>
// - interceptor de response:
//     → si 401 y hay refresh_token: llama a /auth/refresh y reintenta
//     → si el refresh falla: limpia tokens y redirige a /login
//     → cualquier otro error: extrae el mensaje del body y lo muestra
```

---

## Servicios a Crear

| Servicio | Endpoints que cubre |
|----------|---------------------|
| `auth.service.ts` | login, register, logout, refresh, forgotPassword, resetPassword |
| `projects.service.ts` | listar, crear, actualizar, archivar, obtener por ID |
| `files.service.ts` | subir archivo (con progreso), listar, eliminar, obtener preview |
| `aiJobs.service.ts` | crear job, obtener estado, cancelar, listar por proyecto |
| `datasets.service.ts` | listar datasets, obtener lineage, descargar |
| `reports.service.ts` | crear, actualizar, listar versiones, exportar |
| `teams.service.ts` | crear equipo, invitar miembro, cambiar rol, remover |
| `notifications.service.ts` | listar, marcar como leída, marcar todas |

---

## Hooks Principales

### `useAuth`
- Provee: `user`, `isAuthenticated`, `login()`, `logout()`, `register()`
- Persiste el estado entre recargas (localStorage o sessionStorage)
- Disponible en toda la app via contexto

### `useProjects`
- Provee: `projects`, `loading`, `createProject()`, `archiveProject()`
- Se invalida automáticamente cuando se crea o archiva un proyecto

### `useFiles`
- Provee: `uploadFile()` con callback de progreso, `files`, `deleteFile()`

---

## Tareas

1. [ ] Instalar dependencias: `axios`, `msw`.
2. [ ] Crear `services/api.ts` con la instancia base y los interceptors.
3. [ ] Crear `useAuth` hook y conectarlo con el componente `Login.tsx` existente.
4. [ ] Crear `auth.service.ts` y conectar con `Register.tsx`.
5. [ ] Crear `projects.service.ts` y conectar con `ProjectManager.tsx`.
6. [ ] Crear `files.service.ts` con soporte de progreso de subida.
7. [ ] Crear `aiJobs.service.ts` con polling de estado.
8. [ ] Crear mock del API con MSW para los servicios anteriores.
9. [ ] Expandir `packages/shared-types` con todas las interfaces necesarias.
10. [ ] Verificar que los errores del API se muestran usando el `NotificationContext` existente.

---

## Manejo de Tokens

- `access_token` → `sessionStorage` (se pierde al cerrar pestaña).
- `refresh_token` → `localStorage` (persiste entre sesiones si el usuario marcó "recordarme").
- Nunca exponer tokens en URL ni en logs de consola.

## Prioridad

**Alta** — sin esta capa, el prototipo no puede conectarse al backend aunque el backend esté listo.
