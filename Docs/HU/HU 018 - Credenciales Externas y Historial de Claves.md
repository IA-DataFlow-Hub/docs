# HU-018: Soporte de Proveedores de Credenciales y Historial de Claves

## Historia de Usuario
**Como** usuario del sistema IA-DataFlow,  
**Quiero** poder iniciar sesión usando contraseña tradicional o proveedores externos como Google y Apple,  
**Para** tener opciones de autenticación flexibles y seguras sin depender solo de password local.

## Criterios de Aceptación
- La base de datos debe soportar múltiples métodos de autenticación por usuario.
- Debe existir una tabla de proveedores de login (`identity_providers`) para Google, Apple y futuros proveedores.
- Debe existir una tabla de credenciales de usuario (`credentials`) que permita:
  - contraseña local (hash)
  - proveedor externo con `provider_name`, `provider_user_id` y `provider_email`
- Debe guardarse el historial de las últimas 5 contraseñas usadas para cada usuario.
- No se debe permitir reutilizar ninguna de las últimas 5 contraseñas.
- La aplicación debe ser capaz de autenticar por:
  - clave local
  - Google
  - otros proveedores futuros sin alterar el modelo básico.
- Debe registrarse la fecha del último cambio de contraseña y el método de autenticación preferido.

## Análisis de Cambios Requeridos
### Tablas nuevas o modificadas
a) `identity_providers`
- `id_provider` INT AUTO_INCREMENT PRIMARY KEY
- `provider_name` VARCHAR(100) NOT NULL UNIQUE
- `description` TEXT
- `is_active` BOOLEAN DEFAULT TRUE
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

b) `credentials`
- `id_credential` INT AUTO_INCREMENT PRIMARY KEY
- `id_user` INT NOT NULL
- `provider_id` INT NULL
- `provider_user_id` VARCHAR(255) NULL
- `provider_email` VARCHAR(255) NULL
- `password_hash` VARCHAR(255) NULL
- `password_salt` VARCHAR(255) NULL
- `mfa_enabled` BOOLEAN DEFAULT FALSE
- `last_password_change` TIMESTAMP NULL
- `preferred_auth_method` ENUM('password','google','apple','other') DEFAULT 'password'

c) `password_history`
- `id_history` INT AUTO_INCREMENT PRIMARY KEY
- `id_user` INT NOT NULL
- `password_hash` VARCHAR(255) NOT NULL
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Reglas de Negocio
- Si el usuario se registra o autentica por proveedor externo, el registro en `credentials` usa `provider_id`, `provider_user_id` y `provider_email`, y `password_hash` puede quedar NULL.
- Si el usuario usa clave local, `provider_id` debe ser NULL y `password_hash` debe estar presente.
- Cuando una contraseña cambia, el hash anterior se agrega a `password_history`.
- Solo se conservan las últimas 5 entradas de `password_history` por usuario.
- La nueva contraseña no puede coincidir con ninguna de las últimas 5 contraseñas.

## Ejemplo de Funcionamiento Deseado
1. Registro por clave local:
   - `credentials`: `id_user=123`, `provider_id=NULL`, `password_hash='hash'`, `preferred_auth_method='password'`
   - `password_history`: guarda el hash anterior al cambiar contraseña.
2. Login por Google:
   - `identity_providers`: `provider_name='google'`
   - `credentials`: `provider_id=1`,`provider_user_id='google-uid'`,`provider_email='user@gmail.com'`, `password_hash=NULL`, `preferred_auth_method='google'`
3. Después de cambiar contraseña local:
   - Se crea registro en `password_history` con el hash anterior.
   - Se valida que la nueva contraseña no esté en las últimas 5.
4. Futuro proveedor Apple u otro:
   - Solo se añade `identity_providers` con `provider_name='apple'` o `provider_name='microsoft'`.
   - No se cambia la tabla principal.

## Ejemplo SQL de Estructura
```sql
CREATE TABLE identity_providers (
    id_provider INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE credentials (
    id_credential INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    provider_id INT NULL,
    provider_user_id VARCHAR(255) NULL,
    provider_email VARCHAR(255) NULL,
    password_hash VARCHAR(255) NULL,
    password_salt VARCHAR(255) NULL,
    mfa_enabled BOOLEAN DEFAULT FALSE,
    last_password_change TIMESTAMP NULL,
    preferred_auth_method ENUM('password','google','apple','other') DEFAULT 'password',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_credentials_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_credentials_provider FOREIGN KEY (provider_id) REFERENCES identity_providers(id_provider) ON DELETE SET NULL
);

CREATE TABLE password_history (
    id_history INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_password_history_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
);
```

## Reglas para el frontend/backend
- Al registrar con proveedor externo, permitir solo `provider_name`, `provider_user_id` y `provider_email`.
- Al registrar con contraseña, validar fuerza de clave y almacenar hash seguro.
- Al cambiar contraseña, verificar contra `password_history` de las últimas 5 entradas.
- Al iniciar sesión, detectar si el usuario tiene `preferred_auth_method` y presentar opciones.
- El sistema debe permitir agregar nuevos proveedores sin cambios de esquema importantes.

## Prioridad
Media-Alta - Mejora de seguridad y flexibilidad de login, necesario para soportar autenticación moderna.