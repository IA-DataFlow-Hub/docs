# HU-041 — Módulo de Perfil de Usuario y Configuración Personal

> **Asignado:** @dospina56-maker — David Ospina

## Asignación de Tablas

`users` (perfil completo) · `user_statuses` · `user_configurations` · `configuration_keys`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Perfil de Usuario siguiendo Clean Architecture,  
**Para** gestionar la actualización de datos personales, foto de perfil, estado de cuenta y las preferencias individuales del sistema (tema, idioma, notificaciones, tour).

**Dependencia:** Requiere HU-040 (Auth) para el usuario autenticado.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/users/
├── users.module.ts
├── domain/
│   ├── entities/
│   │   ├── user.entity.ts
│   │   └── user-configuration.entity.ts
│   └── repositories/
│       ├── user.repository.interface.ts
│       └── user-configuration.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── update-profile.dto.ts
│   │   ├── upsert-configuration.dto.ts
│   │   ├── user-response.dto.ts
│   │   └── configuration-response.dto.ts
│   ├── use-cases/
│   │   ├── get-user-profile.use-case.ts
│   │   ├── update-user-profile.use-case.ts
│   │   ├── deactivate-user.use-case.ts
│   │   ├── get-user-configurations.use-case.ts
│   │   └── upsert-user-configuration.use-case.ts
│   └── facades/
│       └── users.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── users.controller.ts
    └── persistence/
        ├── prisma-user.repository.ts
        ├── prisma-user-configuration.repository.ts
        └── mappers/
            ├── user.mapper.ts
            └── user-configuration.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Upsert de configuración con validación de esquema

**Dado** que se recibe `UpsertConfigurationDto` con `key_name = 'theme'` y `value = 'light'`  
**Cuando** `UpsertUserConfigurationUseCase` ejecuta  
**Entonces:**
- Consulta `configuration_keys` por `key_name` para obtener el `value_type` y `validation_rules`.
- La entidad `UserConfiguration` valida que `value` esté incluido en `validation_rules.allowed_values`; si no, lanza `InvalidConfigValueException` con el listado de valores permitidos.
- Hace UPSERT en `user_configurations` usando la constraint `uk_user_config (id_user, id_config_key)`: actualiza si existe, inserta si no.
- Retorna `ConfigurationResponseDto` con el `key_name`, `display_name`, `value` resuelto y `value_type`.

### Escenario 2 — Soft-delete de usuario (desactivación de cuenta)

**Dado** que el usuario autenticado solicita desactivar su cuenta  
**Cuando** `DeactivateUserUseCase` ejecuta  
**Entonces:**
- Actualiza `users.deleted_at = now()` y `users.deleted_by = id_usuario_ejecutor`.
- **No elimina físicamente** el registro; aplica el patrón soft-delete.
- Revoca automáticamente todas las sesiones activas del usuario (llama a `RevokeSessionUseCase` del módulo Auth por cada sesión con `status = 'active'`).
- Lanza `UserAlreadyInactiveException` si `deleted_at` ya tiene valor.

### Escenario 3 — Exposición de catálogo de configuraciones disponibles

**Dado** que el frontend necesita mostrar todas las opciones configurables  
**Cuando** `GET /users/configurations/available` es consultado  
**Entonces:**
- Retorna todos los registros de `configuration_keys` con `key_name`, `display_name`, `description`, `value_type`, `default_value` y `validation_rules`.
- El mapper resuelve `validation_rules` como objeto JSON deserializado, no como string.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/users/me` | Perfil del usuario autenticado |
| PATCH | `/users/me` | Actualizar datos personales |
| DELETE | `/users/me` | Desactivar cuenta (soft-delete) |
| GET | `/users/me/configurations` | Todas las configuraciones del usuario |
| PUT | `/users/me/configurations/:key` | Crear o actualizar una configuración |
| GET | `/users/configurations/available` | Catálogo global de claves de configuración |

---

## Notas Técnicas

- `UserRepositoryInterface` es exportada por este módulo y consumida por HU-040 (Auth) para la creación inicial del usuario durante el registro.
- Todas las queries de lectura aplican `WHERE deleted_at IS NULL`.
- El campo `profile_picture` almacena una URL externa (no el archivo); la subida del archivo es responsabilidad del módulo de Archivos (HU-044).
