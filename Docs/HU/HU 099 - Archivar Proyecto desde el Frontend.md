# HU 099 - Archivar Proyecto desde el Frontend

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-093

---

## HU-099: Archivar proyecto desde el frontend

**Como** usuario autenticado,
**quiero** poder archivar un proyecto que ya no está activo,
**para** sacarlo de mi lista de proyectos activos sin eliminarlo permanentemente.

### Criterios de Aceptación
- El sistema debe mostrar una opción "Archivar proyecto" en el menú de opciones del `ProjectManager` (junto a Editar y Eliminar)
- El sistema debe mostrar un diálogo de confirmación ("¿Archivar este proyecto? Podrás consultarlo pero no editarlo")
- El sistema debe llamar a `POST /projects/:id/archive` al confirmar
- El sistema debe remover el proyecto de la lista de proyectos activos en el contexto local tras respuesta exitosa
- El sistema debe seleccionar automáticamente otro proyecto activo si se archiva el proyecto actualmente activo
- El sistema debe mostrar error 403 si el usuario no tiene permisos para archivar

### Notas
- Diferencia clave con Eliminar (HU-093): archivar no borra — el proyecto sigue existiendo con estado archivado
- Depende de HU-093 (ProjectManager conectado a API)
