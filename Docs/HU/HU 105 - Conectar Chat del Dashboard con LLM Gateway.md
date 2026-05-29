# HU 105 - Conectar Chat del Dashboard con LLM Gateway

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-080, HU-104

---

## HU-105: Conectar el chat conversacional del Dashboard con el LLM Gateway

**Como** usuario autenticado,
**quiero** que el chat del Dashboard envíe mis mensajes al LLM Gateway real y muestre la respuesta del modelo de IA en tiempo real (streaming token a token),
**para** que la conversación sea funcional en lugar de usar respuestas hardcodeadas.

### Criterios de Aceptación

#### Envío de mensajes
- El sistema debe llamar a `POST /v1/chat/completions` al hacer clic en "Enviar" en el chat del Dashboard
- El sistema debe enviar como `messages` el historial completo de la conversación actual (roles `system`, `user`, `assistant`)
- El sistema debe incluir un mensaje de sistema (`role: "system"`) que contextualice al modelo sobre el ciclo BPM de IA-DataFlow Hub
- El sistema debe usar `stream: true` por defecto para mostrar la respuesta token a token
- El sistema debe deshabilitar el input y el botón de envío mientras la respuesta está en progreso

#### Rendering de streaming
- El sistema debe mostrar los tokens de la respuesta en tiempo real a medida que llegan del SSE stream
- El sistema debe mostrar un cursor parpadeante o indicador de "escribiendo..." mientras el stream está activo
- El sistema debe agregar el mensaje del asistente completo al historial local cuando el stream finaliza (`data: [DONE]`)
- El sistema debe renderizar correctamente markdown en las respuestas (negrita, listas, bloques de código)

#### Selección de modelo
- El sistema debe llamar a `GET /v1/models` al cargar el Dashboard para obtener modelos disponibles
- El sistema debe mostrar un selector de modelo en la UI del chat (o en configuración) con la lista obtenida
- El sistema debe persistir el modelo seleccionado en `localStorage` y enviarlo en cada request

#### Manejo de errores
- El sistema debe mostrar un mensaje de error inline en el chat si la API retorna `502` (LM Studio no disponible): "El modelo de IA no está disponible en este momento"
- El sistema debe mostrar un mensaje de error si retorna `429`: "Has alcanzado el límite de solicitudes. Intenta en X segundos"
- El sistema debe permitir reintentar el último mensaje con un botón "Reintentar" visible en el mensaje de error
- El sistema debe manejar la desconexión del stream SSE y mostrar lo generado hasta ese punto

#### Contexto BPM
- El sistema debe inyectar automáticamente el mensaje de sistema con la fase actual del proyecto y el ciclo BPM:
  ```
  Eres un asistente experto en ETL y análisis de datos para IA-DataFlow Hub.
  El proyecto actual está en la fase: {currentPhase}.
  Ciclo BPM: DISEÑAR → EJECUTAR → SUPERVISAR → OPTIMIZAR.
  ```
- El sistema debe limpiar el historial de chat al cambiar de proyecto o de fase

### Notas
- El chat en `Dashboard.tsx` actualmente usa `simulateBPMFlow()` con respuestas hardcodeadas — reemplazar esa función por llamadas reales al LLM Gateway
- El historial de mensajes (`chatMessages` state) se mapea directamente al array `messages` del request, filtrando los mensajes de sistema de UI (tipo `phase` indicator)
- Depende de HU-075 (cliente HTTP con JWT), HU-080 (rutas protegidas), HU-104 (backend LLM Gateway)
- Librería recomendada para SSE en el cliente: `EventSource` nativo o `@microsoft/fetch-event-source` para poder enviar headers de autorización (el `EventSource` nativo no soporta headers)
