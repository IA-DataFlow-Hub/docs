# HU-034 — Flujos Base en n8n

## Historia de Usuario

**Como** equipo de desarrollo,  
**Quiero** tener los flujos principales de automatización construidos en n8n,  
**Para** poder procesar archivos con IA, enviar notificaciones y ejecutar pipelines ETL sin depender de que el backend esté completo.

---

## Contexto

n8n ya está corriendo en Docker (`http://localhost:5678`). Esta HU construye los flujos que el sistema necesita para funcionar. Los flujos se conectarán al backend vía webhooks cuando el API esté listo — por ahora se prueban de forma independiente.

---

## Criterios de Aceptación

- [ ] Cada flujo está exportado como `.json` en `infra/n8n/workflows/`.
- [ ] Cada flujo tiene nombre descriptivo y nodos con etiquetas claras.
- [ ] Los flujos pueden ejecutarse manualmente para pruebas.
- [ ] Las credenciales (API keys, SMTP) están en variables de entorno de n8n, no hardcodeadas.
- [ ] Cada flujo tiene un nodo de manejo de error que notifica si algo falla.

---

## Flujos a Construir

---

### Flujo 1 — Procesamiento de Archivo con IA

**Trigger:** Webhook POST desde el backend con `{ file_path, instructions, engine }`  
**Pasos:**
1. Recibir webhook con ruta del archivo e instrucciones del usuario.
2. Leer el archivo (CSV/Excel) desde el volumen compartido.
3. Llamar al motor de IA seleccionado (Ollama o Gemini) con el prompt correspondiente.
4. Guardar el archivo resultado en el volumen.
5. Notificar al backend vía webhook con `{ job_id, status, result_path }`.

**Casos de error:**
- Si Gemini falla → reintentar con Ollama automáticamente.
- Si ambos fallan → notificar al backend con `status: failed`.

---

### Flujo 2 — Notificación de Job Completado

**Trigger:** Webhook POST desde el backend con `{ user_email, job_id, status, result_url }`  
**Pasos:**
1. Recibir notificación de job terminado.
2. Enviar email al usuario con resultado y enlace al archivo procesado.
3. (Opcional) Enviar notificación push si hay token de dispositivo.

**Template del email:**
```
Asunto: Tu análisis está listo — IA DataFlow Hub
Cuerpo: "Hola [nombre], tu archivo fue procesado correctamente.
         Ver resultado: [enlace]"
```

---

### Flujo 3 — Pipeline ETL Básico

**Trigger:** Webhook POST con `{ file_path, template_id, steps[] }`  
**Pasos:**
1. Recibir archivo y lista de pasos del template ETL.
2. Ejecutar cada paso en orden:
   - Eliminar filas vacías
   - Estandarizar formato de fechas
   - Normalizar columnas de texto (trim, lowercase)
   - Eliminar duplicados
3. Guardar archivo transformado.
4. Notificar al backend con el resultado.

---

### Flujo 4 — Healthcheck de Servicios

**Trigger:** Programado cada 5 minutos  
**Pasos:**
1. Verificar que el API responde (`GET /health`).
2. Verificar que Ollama responde (`GET http://ollama:11434`).
3. Verificar que MySQL está accesible.
4. Si alguno falla → enviar email de alerta al equipo.

---

### Flujo 5 — Análisis Automático al Subir Archivo

**Trigger:** Webhook POST cuando el backend registra un archivo nuevo  
**Pasos:**
1. Recibir `{ file_id, file_path }`.
2. Enviar el archivo a Ollama con el prompt de "análisis de estructura".
3. Devolver al backend: número de columnas, tipos detectados, filas, anomalías encontradas.

Este análisis aparece en la vista previa del archivo en el frontend.

---

## Estructura de Archivos

```
infra/n8n/
├── workflows/
│   ├── 01-procesamiento-ia.json
│   ├── 02-notificacion-job.json
│   ├── 03-pipeline-etl-basico.json
│   ├── 04-healthcheck.json
│   └── 05-analisis-al-subir.json
└── README.md          ← cómo importar y configurar los flujos
```

---

## Dependencias

- **HU-033** — Entorno de IA debe estar listo para los flujos 1 y 5.
- Volumen compartido entre n8n y el API para acceder a los archivos.
- SMTP configurado en n8n para los flujos de notificación.

## Prioridad

**Alta** — Flujos 1 y 3 son el núcleo del sistema. Flujos 2 y 4 son necesarios antes de salir a producción.
