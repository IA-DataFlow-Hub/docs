# HU-024 — Gestión Avanzada de Sesiones y Dispositivos

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero visualizar y administrar mis sesiones activas,

para saber desde qué navegador, dispositivo y ubicación tengo acceso al sistema, detectar accesos sospechosos y cerrar sesiones activas remotamente.

---

# Objetivo

Mejorar el sistema de sesiones para:

- Detectar navegador y dispositivo
- Saber si una sesión está activa
- Registrar actividad reciente
- Gestionar múltiples dispositivos
- Cerrar sesiones manualmente
- Mejorar seguridad y auditoría

---

# Requerimientos Funcionales

## RF-01 — Registro de dispositivo

El sistema debe almacenar:

- navegador
- sistema operativo
- tipo de dispositivo
- IP
- ubicación aproximada
- user agent completo

---

## RF-02 — Estado de sesión

El sistema debe determinar si la sesión está:

- active
- inactive
- expired
- revoked

---

## RF-03 — Última actividad

Cada sesión debe registrar:

- último acceso
- última acción realizada
- última actualización de heartbeat

---

## RF-04 — Sesiones múltiples

El usuario podrá tener múltiples sesiones activas simultáneamente.

Ejemplo:

- Chrome Windows
- Edge Windows
- Android App
- Firefox Linux

---

## RF-05 — Cierre remoto de sesión

El usuario podrá:

- cerrar una sesión específica
- cerrar todas las demás sesiones

---

## RF-06 — Identificación visual

La interfaz debe mostrar:

- navegador
- sistema operativo
- dispositivo
- IP
- ubicación aproximada
- fecha de inicio
- última actividad
- sesión actual

---

## RF-07 — Seguridad

El sistema debe detectar:

- sesiones duplicadas sospechosas
- cambios bruscos de IP
- dispositivos desconocidos

---

# Diseño Técnico

---

# Tabla Mejorada: sessions

```sql
CREATE TABLE sessions (
    id_session INT AUTO_INCREMENT PRIMARY KEY,

    id_user INT NOT NULL,

    session_token VARCHAR(255) NOT NULL UNIQUE,
    refresh_token VARCHAR(255) NULL,

    ip_address VARCHAR(45),

    user_agent TEXT,

    browser_name VARCHAR(100),
    browser_version VARCHAR(50),

    operating_system VARCHAR(100),
    operating_system_version VARCHAR(50),

    device_type ENUM(
        'desktop',
        'mobile',
        'tablet',
        'bot',
        'unknown'
    ) DEFAULT 'unknown',

    device_name VARCHAR(150),

    country VARCHAR(100),
    city VARCHAR(100),

    is_current BOOLEAN DEFAULT FALSE,

    status ENUM(
        'active',
        'inactive',
        'expired',
        'revoked'
    ) DEFAULT 'active',

    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    expires_at TIMESTAMP NULL DEFAULT NULL,

    revoked_at TIMESTAMP NULL DEFAULT NULL,

    revoke_reason VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_sessions_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);
```

---

# Índices Recomendados

```sql
CREATE INDEX idx_sessions_user
    ON sessions(id_user);

CREATE INDEX idx_sessions_status
    ON sessions(status);

CREATE INDEX idx_sessions_last_activity
    ON sessions(last_activity_at);

CREATE INDEX idx_sessions_token
    ON sessions(session_token);
```

---

# Reglas de Negocio

## Sesión Activa

Una sesión se considera activa cuando:

```text
NOW() - last_activity_at <= 15 minutos
```

---

## Heartbeat

Frontend debe actualizar:

```text
last_activity_at
```

cada:

```text
30 - 60 segundos
```

---

## Expiración

Una sesión expira cuando:

```text
NOW() > expires_at
```

---

## Revocación

Una sesión revocada:

- invalida token
- obliga relogin
- se excluye de sesiones activas

---

# Casos de Uso

## Caso 1 — Ver sesiones activas

Usuario abre:

```text
Perfil → Seguridad → Sesiones
```

y visualiza:

- Chrome Windows
- Android Mobile
- Edge Linux

---

## Caso 2 — Detectar acceso sospechoso

Sistema detecta:

- IP distinta
- país distinto
- nuevo dispositivo

y genera alerta.

---

## Caso 3 — Cerrar sesión remota

Usuario presiona:

```text
Cerrar otras sesiones
```

y el sistema:

- revoca tokens
- cambia status = revoked

---

# Beneficios

- Mayor seguridad
- Control de dispositivos
- Auditoría avanzada
- Prevención de accesos indebidos
- Mejor experiencia multi-dispositivo

---

# Posibles Mejoras Futuras

- MFA por dispositivo
- Historial de ubicaciones
- Detección de sesiones robadas
- Notificaciones de nuevo login
- Mapa de accesos
- Fingerprint avanzado
- Riesgo de sesión por IA
- Integración con OAuth providers

---