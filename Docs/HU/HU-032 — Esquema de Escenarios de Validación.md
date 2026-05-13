# HU-032 — Esquema de Escenarios de Validación del Proyecto

## Historia de Usuario

**Como** equipo de desarrollo de IA-DataFlow-Hub,  
**Quiero** tener un mapa de los escenarios que debemos verificar cuando el sistema esté funcionando,  
**Para** saber qué flujos y comportamientos confirmar antes de considerar el proyecto listo.

---

## Contexto

Este documento describe **qué validar en el producto terminado**: los flujos de usuario, reglas de negocio y casos borde del frontend integrado con backend e IA.

No describe cómo implementar pruebas ni valida HUs individuales — eso se asume resuelto.

Los escenarios usan tres marcadores:
- ✅ **Camino feliz** — lo que debe ocurrir normalmente.
- ❌ **No debe ocurrir** — errores, accesos indebidos, datos corruptos.
- ⚠️ **Caso borde** — situaciones límite que podrían romper el sistema.

---

# Flujo 1 — Registro y Acceso

✅ Un usuario nuevo puede registrarse, confirmar su cuenta y entrar al sistema.  
✅ Puede iniciar sesión con usuario/contraseña o con Google.  
✅ Puede recuperar su contraseña por correo electrónico.  
✅ Puede ver y cerrar sus sesiones activas en otros dispositivos.  
❌ No puede registrarse con un email ya existente.  
❌ No puede iniciar sesión tras 5 intentos fallidos (bloqueo temporal).  
❌ Un token de sesión expirado no da acceso.  
⚠️ Si el usuario tiene solo Google login y lo desvincula, ¿puede seguir entrando?  
⚠️ Un enlace de recuperación de contraseña debe expirar y no reutilizarse.

---

# Flujo 2 — Proyectos y Equipo

✅ El usuario puede crear proyectos, archivarlos y ver solo los propios o de su equipo.  
✅ Puede invitar colaboradores al equipo por email; el invitado recibe correo y al aceptar queda con rol por defecto.  
✅ El administrador puede cambiar roles o remover miembros.  
✅ Un usuario puede tener distintos roles en distintos equipos y proyectos simultáneamente.  
❌ Un usuario sin permiso no puede ver proyectos privados de otros.  
❌ Un miembro sin rol admin no puede gestionar otros miembros.  
⚠️ Si el único admin del equipo se elimina a sí mismo, ¿queda el equipo sin administrador?  
⚠️ Al remover a un miembro, debe perder acceso inmediato a todos los recursos del equipo.

---

# Flujo 3 — Subida y Gestión de Archivos

✅ El usuario puede subir CSV, Excel (.xlsx) y JSON con barra de progreso visible.  
✅ Al terminar, ve una vista previa de las primeras filas del archivo.  
✅ Puede eliminar un archivo (eliminación lógica, el dato no desaparece de la base).  
✅ Un Excel con múltiples hojas permite elegir cuál usar.  
❌ No se aceptan formatos no soportados (.exe, .png, .pdf, etc.).  
❌ El archivo original nunca se modifica por ningún proceso.  
⚠️ ¿Qué pasa si el CSV tiene encoding incorrecto o caracteres especiales (tildes, ñ)?  
⚠️ ¿Qué pasa si el usuario cierra el navegador a mitad de la subida?  
⚠️ ¿Qué pasa si se sube el mismo archivo dos veces?

---

# Flujo 4 — Chat con IA y Procesamiento

✅ El usuario puede abrir una conversación sobre un archivo y escribir instrucciones en lenguaje natural.  
✅ La IA responde, describe lo que hizo y entrega un enlace al archivo resultado.  
✅ El historial del chat persiste entre sesiones.  
✅ Si la IA usa Gemini y falla, el sistema hace fallback a Llama local sin que el usuario lo note.  
✅ El usuario puede dar pulgar arriba/abajo a cada respuesta de la IA.  
❌ La IA no puede responder con datos de otro usuario.  
❌ Si el proceso de IA falla, el chat no se bloquea — el usuario puede seguir escribiendo.  
⚠️ ¿Qué pasa si el archivo asociado al chat fue eliminado después de iniciar la conversación?  
⚠️ ¿Qué pasa si la instrucción es ambigua? ¿La IA pide aclaración o actúa de todas formas?

---

# Flujo 5 — Templates ETL

✅ El usuario puede crear templates con pasos de transformación y reutilizarlos en distintos archivos.  
✅ Al aplicar un template, se genera un archivo nuevo — el original no cambia.  
✅ Puede ver el historial de ejecuciones de cada template.  
✅ Puede compartir templates con su equipo o mantenerlos privados.  
❌ Un template privado no aparece en la lista de otros usuarios.  
⚠️ ¿Qué pasa si el template espera una columna que no existe en el archivo destino?  
⚠️ ¿Modificar un template ya ejecutado afecta las ejecuciones pasadas?

---

# Flujo 6 — Datasets y Trazabilidad

✅ Cada dataset generado sabe de qué archivo vino y qué job de IA lo produjo.  
✅ Se puede ver la cadena completa: archivo original → transformación → dataset resultante.  
✅ Los archivos pesados se guardan fuera de MySQL; en la base solo queda metadata.  
❌ Un dataset sin origen trazable no debería poder existir.  
⚠️ ¿Qué pasa si el archivo físico del dataset se elimina del disco pero el registro en la base sigue?

---

# Flujo 7 — Reportes y Dashboards

✅ El usuario puede crear reportes con widgets (gráficos, tablas, KPIs) sobre un dataset.  
✅ Cada vez que guarda cambios se crea una nueva versión; puede regresar a versiones anteriores.  
✅ Puede compartir el reporte con su equipo (solo lectura o edición) y exportarlo a PDF.  
❌ Compartir un reporte no da acceso automático al dataset completo.  
❌ Dos usuarios editando el mismo reporte al mismo tiempo no deben sobreescribirse sin advertencia.  
⚠️ ¿Qué pasa si el dataset del reporte cambia de estructura (columnas renombradas o eliminadas)?

---

# Flujo 8 — Notificaciones y Feed de Actividad

✅ El usuario recibe notificaciones cuando un job de IA termina, cuando lo mencionan o cuando le asignan una tarea.  
✅ Puede marcar notificaciones como leídas y el contador se actualiza en tiempo real.  
✅ El feed de actividad muestra cronológicamente los eventos del proyecto con autor y fecha.  
❌ El usuario no recibe notificaciones ni ve eventos de proyectos a los que no pertenece.  
❌ Un mismo evento no genera entradas duplicadas en el feed.  
⚠️ ¿Las notificaciones expiran o se acumulan indefinidamente?

---

# Reglas Transversales

| Área | Regla |
|------|-------|
| Seguridad | Recurso sin permiso → responde 404, no 403 (no revela existencia). |
| Sesiones | Access token: 15 min. Refresh token: 7 días. |
| Eliminación | Todo es soft delete. Nada se borra físicamente en tablas operativas. |
| Auditoría | Todo cambio registra quién lo hizo, cuándo y el valor anterior. |
| Archivos | Los datos de datasets nunca se almacenan en MySQL. |
| UX | Cualquier acción que tarde más de 1 segundo muestra indicador de carga. |
| Errores | El usuario recibe mensajes claros, nunca un stack trace. |

---

## Prioridad

**Alta** — revisar este documento al comenzar las pruebas del sistema integrado, no antes.
