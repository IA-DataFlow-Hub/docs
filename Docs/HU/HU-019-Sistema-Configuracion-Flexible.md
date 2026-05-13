# HU-019: Sistema de Configuración Flexible para Preferencias de Usuario

## Historia de Usuario
**Como** administrador del sistema IA-DataFlow,  
**Quiero** un sistema de configuración de usuario escalable y flexible,  
**Para** agregar nuevas preferencias sin modificar el esquema de la base de datos y permitir configuraciones complejas.

## Criterios de Aceptación
- Reemplazar la tabla `user_preferences` con un sistema clave-valor.
- Crear tabla `configuration_keys` para definir configuraciones disponibles.
- Crear tabla `user_configurations` para almacenar valores por usuario.
- Soporte para tipos de valor: string, boolean, number, json (para objetos complejos).
- Permitir categorías de configuración (ej. 'ui', 'notifications', 'ai').
- Valores por defecto definidos en `configuration_keys`.
- La aplicación debe poder agregar nuevas configuraciones dinámicamente.
- Migrar datos existentes de `user_preferences` a las nuevas tablas.

## Análisis de Cambios Requeridos
### Tablas nuevas
a) `configuration_keys`
- `id_config_key` INT AUTO_INCREMENT PRIMARY KEY
- `key_name` VARCHAR(100) NOT NULL UNIQUE
- `display_name` VARCHAR(255) NOT NULL
- `description` TEXT
- `category` VARCHAR(100) NOT NULL
- `value_type` ENUM('string','boolean','number','json') NOT NULL
- `default_value` TEXT NULL
- `is_required` BOOLEAN DEFAULT FALSE
- `validation_rules` JSON NULL  -- Para reglas como min/max, opciones permitidas
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

b) `user_configurations`
- `id_user_config` INT AUTO_INCREMENT PRIMARY KEY
- `id_user` INT NOT NULL
- `id_config_key` INT NOT NULL
- `value` TEXT NOT NULL
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- UNIQUE KEY `uk_user_config` (`id_user`, `id_config_key`)
- CONSTRAINT fk_user_config_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
- CONSTRAINT fk_user_config_key FOREIGN KEY (id_config_key) REFERENCES configuration_keys(id_config_key) ON DELETE CASCADE

### Migración de Datos
- Insertar configuraciones iniciales en `configuration_keys`:
  - has_completed_tour: boolean, default FALSE, category 'ui'
  - theme: string, default 'dark', category 'ui', validation_rules: ['dark','light','system']
  - language: string, default 'es', category 'ui'
  - notifications_enabled: boolean, default TRUE, category 'notifications'
- Migrar valores existentes de `user_preferences` a `user_configurations`.

### Ejemplo de Uso
1. Agregar nueva configuración: Insertar en `configuration_keys` con key_name='dashboard_layout', value_type='json', default_value='{"widgets": ["chart","table"]}'
2. Usuario personaliza: Insertar/actualizar en `user_configurations` con value='{"widgets": ["chart","map","table"]}'
3. Recuperar configuración: JOIN entre `configuration_keys` y `user_configurations`, usando default_value si no hay valor personalizado.

## Ejemplo SQL de Estructura
```sql
CREATE TABLE configuration_keys (
    id_config_key INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    value_type ENUM('string','boolean','number','json') NOT NULL,
    default_value TEXT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    validation_rules JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE user_configurations (
    id_user_config INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_config_key INT NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_config (id_user, id_config_key),
    CONSTRAINT fk_user_config_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_user_config_key FOREIGN KEY (id_config_key) REFERENCES configuration_keys(id_config_key) ON DELETE CASCADE
);
```

## Ventajas
- Escalabilidad: Agregar configuraciones sin ALTER TABLE.
- Flexibilidad: Soporte para objetos JSON complejos.
- Validación: Reglas de validación por configuración.
- Default values: Valores por defecto manejados automáticamente.

## Tareas Técnicas
1. Crear las nuevas tablas.
2. Insertar configuraciones iniciales.
3. Migrar datos existentes.
4. Actualizar código de aplicación para usar el nuevo sistema.
5. Eliminar tabla `user_preferences` después de migración.

## Prioridad
Media - Mejora la mantenibilidad y escalabilidad del sistema de configuraciones.