# HU-020: Modelo de Roles por Equipo, Proyecto y Grupo Personal

## Historia de Usuario
**Como** administrador del sistema IA-DataFlow,  
**Quiero** un modelo de roles flexible que soporte roles predeterminados, roles específicos de equipo y roles específicos de proyecto,  
**Para** que un usuario pueda tener diferentes responsabilidades en distintos equipos y proyectos sin romper la independencia ni la herencia de permisos.

## Criterios de Aceptación
- Debe existir un conjunto de roles predeterminados globales (`user`, `admin`, `supervisor`) usados como plantilla inicial.
- Cada equipo debe tener su propio conjunto de roles, que hereden permisos del rol predeterminado al crearse pero puedan personalizarse localmente.
- Si un rol predeterminado cambia, NO debe modificar roles ya creados en equipos existentes.
- Cada usuario debe pertenecer a un grupo personal (`personal_group`) si no está en un equipo, para poder trabajar individualmente.
- Los usuarios pueden tener roles por persona y equipo (`user_team_roles`).
- Los usuarios también pueden tener roles por proyecto (`user_project_roles`), pudiendo sobrescribir la herencia de su equipo en ese proyecto.
- Los permisos de proyecto deben tomar los permisos del rol de proyecto o, si no existe, heredar el rol del equipo correspondiente.
- Los roles creados por un equipo no deben ser visibles ni aplicables a otros equipos.
- Los permisos se asignan a roles dentro del ámbito de cada equipo o proyecto.

## Análisis de Cambios Requeridos
### Tablas nuevas / rediseño
1. `role_templates`
   - `id_role_template` INT AUTO_INCREMENT PRIMARY KEY
   - `template_name` VARCHAR(100) NOT NULL UNIQUE
   - `description` TEXT
   - `created_at`, `updated_at`
   - Ejemplos: `user`, `admin`, `supervisor`

1b. `role_template_permissions`
   - `id_role_template_permission` INT AUTO_INCREMENT PRIMARY KEY
   - `id_role_template` INT NOT NULL
   - `id_permission` INT NOT NULL
   - `created_at`, `updated_at`
   - Define los permisos que trae cada rol predeterminado.

2. `team_roles`
   - `id_team_role` INT AUTO_INCREMENT PRIMARY KEY
   - `id_team` INT NOT NULL
   - `role_name` VARCHAR(100) NOT NULL
   - `description` TEXT
   - `is_default` BOOLEAN DEFAULT FALSE
   - `template_id` INT NULL  -- referencia a `role_templates` para heredar permisos iniciales
   - `created_at`, `updated_at`
   - Constraint UNIQUE (`id_team`, `role_name`)

3. `team_role_permissions`
   - `id_team_role_permission` INT AUTO_INCREMENT PRIMARY KEY
   - `id_team_role` INT NOT NULL
   - `id_permission` INT NOT NULL
   - `created_at`, `updated_at`

4. `user_team_roles`
   - `id_user_team_role` INT AUTO_INCREMENT PRIMARY KEY
   - `id_user` INT NOT NULL
   - `id_team` INT NOT NULL
   - `id_team_role` INT NOT NULL
   - `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   - Constraint UNIQUE (`id_user`, `id_team`, `id_team_role`)

5. `user_project_roles`
   - `id_user_project_role` INT AUTO_INCREMENT PRIMARY KEY
   - `id_user` INT NOT NULL
   - `id_project` INT NOT NULL
   - `id_team_role` INT NOT NULL  -- rol del equipo que se aplica en el proyecto
   - `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   - Constraint UNIQUE (`id_user`, `id_project`)

6. `groups` o `teams` con `group_type`
   - Para soportar la idea de grupo personal, se puede extender `teams` con `group_type VARCHAR(50)` y `is_personal_group BOOLEAN`.
   - En `teams`, cada usuario puede tener un grupo personal creado automáticamente al registrarse.
   - Usar texto evita el problema de escalabilidad al agregar nuevos tipos de grupos en el futuro.

### Flujo de creación y herencia
- Al crear un equipo, se crean roles por defecto para ese equipo basados en `role_templates`.
- Cambios en roles de equipo se aplican solo dentro de ese equipo.
- Si un equipo personaliza permisos del rol `user`, el cambio no afecta a otros equipos.
- Si un proyecto no tiene rol explícito para el usuario, hereda el rol de su equipo para ese proyecto.
- Si el proyecto asigna un rol diferente, ese rol se aplica solo a ese proyecto.

## Ejemplo de Escenario
1. Usuario Alice pertenece a Team A y Team B.
2. En Team A, Alice es `admin`.
3. En Team B, Alice es `user`.
4. En Project A1 (perteneciente a Team A), Alice hereda el rol `admin` a menos que se le asigne un rol de proyecto diferente.
5. Si Alice recibe rol `supervisor` en Project A1, ese rol se aplica solo en ese proyecto.
6. Si Team A modifica los permisos de `user`, solo afectará a Team A.
7. Si el rol predeterminado global `user` cambia, no modifica los roles ya creados en Team A ni Team B.

## Permisos de Roles Predeterminados
- `user`: permisos básicos de consumo, ver proyectos, ver tareas y cargar archivos.
- `admin`: permisos completos de gestión de equipo, usuarios, proyectos y configuración.
- `supervisor`: permisos de supervisión y revisión, ver auditoría, aprobar tareas y revisar resultados.

## Reglas de Negocio Adicionales
- Cada equipo hereda los roles predeterminados inicialmente, pero luego su conjunto de roles es independiente.
- Los roles de equipo pueden ser creados por el equipo y no deben aparecer en otros equipos.
- Cada usuario sin equipo debe tener un `personal_group` que le represente como equipo individual.
- Los permisos se resuelven en el siguiente orden:
  1. `user_project_roles` si existe para el proyecto
  2. `user_team_roles` del equipo propietario del proyecto
  3. `personal_group` si no hay equipo asociado

## Ejemplo SQL de Tablas Clave
```sql
CREATE TABLE role_templates (
    id_role_template INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE team_roles (
    id_team_role INT AUTO_INCREMENT PRIMARY KEY,
    id_team INT NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    template_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_role (id_team, role_name),
    CONSTRAINT fk_team_roles_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE CASCADE,
    CONSTRAINT fk_team_roles_template FOREIGN KEY (template_id) REFERENCES role_templates(id_role_template) ON DELETE SET NULL
);

CREATE TABLE team_role_permissions (
    id_team_role_permission INT AUTO_INCREMENT PRIMARY KEY,
    id_team_role INT NOT NULL,
    id_permission INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_team_role_permissions_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE,
    CONSTRAINT fk_team_role_permissions_permission FOREIGN KEY (id_permission) REFERENCES permissions(id_permission) ON DELETE CASCADE
);

CREATE TABLE user_team_roles (
    id_user_team_role INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_team INT NOT NULL,
    id_team_role INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_team_role (id_user, id_team, id_team_role),
    CONSTRAINT fk_user_team_roles_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_user_team_roles_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE CASCADE,
    CONSTRAINT fk_user_team_roles_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE
);

CREATE TABLE user_project_roles (
    id_user_project_role INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_project INT NOT NULL,
    id_team_role INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_project_role (id_user, id_project),
    CONSTRAINT fk_user_project_roles_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_user_project_roles_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_user_project_roles_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE
);
```

## Tareas Técnicas
1. Redefinir el modelo de roles en base de datos para equipos, proyectos y grupos personales.
2. Agregar roles predeterminados globales y rol de equipo independiente.
3. Implementar tablas de asociación `user_team_roles` y `user_project_roles`.
4. Ajustar permisos por rol dentro de cada equipo y proyecto.
5. Actualizar lógica de negocio para heredar roles de equipo en proyectos.
6. Documentar el nuevo flujo de permisos para equipos y proyectos.

## Prioridad
Alta - Es necesario para modelar correctamente el acceso multi-equipo y multi-proyecto en IA-DataFlow.