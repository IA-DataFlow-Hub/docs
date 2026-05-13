# HU-021: Proyectos con Creación Auditada y Relación Archivos ↔ Conversaciones ↔ Mensajes

## Historia de Usuario
**Como** administrador del sistema IA-DataFlow,  
**Quiero** que la tabla `projects` use `created_by` en lugar de `id_user`,  
**Para** separar claramente quién creó el proyecto del usuario asociado y evitar modelos confusos de ownership.

## Criterios de Aceptación
- El campo `id_user` en `projects` debe eliminarse si se agrega `created_by`.
- `projects` debe mantener un campo de autor/creador claro: `created_by INT NOT NULL`.
- Debe existir un campo adicional para el responsable o dueño del proyecto si se necesita separar del creador, por ejemplo `owner_user_id` o `project_owner_id`.
- Un proyecto puede tener varias conversaciones (`conversations`).
- Cada conversación puede tener varios archivos relacionados.
- Cada archivo debe saber en qué conversación se cargó.
- Cada archivo debe poder saber además a qué mensaje está asociado, si aplica.
- La relación entre archivos, conversaciones y mensajes debe quedar explícita en el esquema.
- La HU debe proponer un modelo que no dependa de campos redundantes y que permita consultas directas como: "obtener todos los archivos de la conversación X" o "saber en qué mensaje se subió este archivo".

## Análisis y Cambios Requeridos
### Proyectos
- Quitar `id_user INT NOT NULL` de la tabla `projects` si se añade `created_by`.
- Usar `created_by INT NOT NULL` para referenciar al usuario que creó el proyecto.
- Opcional: agregar `owner_user_id INT NULL` para representar el responsable actual del proyecto.

### Conversaciones y archivos
- Actualmente `files` solo referencia `id_project`, lo que no permite saber en qué conversación se cargaron.
- Se debe agregar `id_conversation INT NULL` a `files` para amarrar el archivo a una conversación específica.
- Para capturar el mensaje, se debe agregar `id_message INT NULL` a `files` o usar una tabla intermedia `conversation_files` con `id_message`.
- Al guardar un archivo, el sistema debe registrar:
  - proyecto al que pertenece
  - conversación en la que se cargó
  - mensaje asociado que originó la carga (si aplica)

### Modelo sugerido
- `projects`: `created_by`, opcional `owner_user_id`, `id_team`, `current_phase`, `id_privacy_level`, `id_status`.
- `files`: agregar `id_conversation INT NULL`, `id_message INT NULL`.
- `conversations`: ya existe y se usa como chat.
- `messages`: puede ser origen de un archivo; el archivo debe poder apuntar a `id_message`.

### Consultas que deben ser posibles
- Obtener todos los archivos de una conversación: `SELECT * FROM files WHERE id_conversation = ?`
- Saber en qué conversación y mensaje se cargó un archivo: `id_conversation`, `id_message`
- Listar archivos por proyecto y conversación.

## Impacto en el esquema
- Se reduce la ambigüedad en `projects` y se mejora la trazabilidad de creación.
- Se mejora la navegación de archivos dentro de chats (`conversations`).
- Se adapta el modelo al concepto correcto: "chat" = `conversations`.

## Tareas Técnicas
1. Eliminar `id_user` de `projects` y agregar `created_by`.
2. Evaluar si se necesita `owner_user_id` en `projects`.
3. Agregar `id_conversation` y `id_message` a `files`.
4. Actualizar la lógica de carga de archivos para guardar conversación y mensaje origen.
5. Ajustar consultas y la capa de aplicación para usar las nuevas relaciones.
6. Documentar el nuevo modelo en el esquema de base de datos.

## Prioridad
Alta - Necesario para que el historial de archivos y chats sea consistente y trazable.