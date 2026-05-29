# HU 104 - Módulo LLM Gateway — API de Inferencia IA

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)

---

## HU-104: Módulo backend LLM Gateway con estándar OpenAI-compatible

**Como** desarrollador del sistema,
**quiero** un módulo NestJS `llm-gateway` que exponga una API de inferencia IA siguiendo el estándar OpenAI-compatible (igual que LM Studio),
**para** que el frontend y el módulo `ai-jobs` puedan obtener respuestas del modelo de IA usando una única capa de acceso, sin importar qué proveedor esté detrás.

---

## Análisis arquitectónico — ¿Qué pasa con `ai-jobs`?

> Decisión evaluada antes de implementar esta HU.

### Módulos actuales de IA en el sistema

| Módulo | Propósito | Naturaleza |
|--------|-----------|------------|
| `ai-jobs` | Orquesta trabajos asíncronos de IA con cola, reintentos, eventos y resultados | **Batch / async** |
| `llm-gateway` *(nuevo)* | Expone la API de chat en tiempo real y centraliza el acceso al proveedor LM Studio | **Real-time / sync+streaming** |

### ¿Se elimina `ai-jobs`?

**No.** Son capas complementarias, no competidoras:

```
Frontend
   │
   ├─ POST /v1/chat/completions ──→ llm-gateway  ──→ LM Studio
   │   (chat en tiempo real, streaming token a token)
   │
   └─ POST /projects/:id/ai-jobs ──→ ai-jobs ──→ cola ──→ Worker
       (jobs batch asíncronos: generación masiva, fine-tuning, análisis pesado)
                                                      │
                                                      └──→ llm-gateway.LlmProviderPort
                                                           (el worker usa el mismo proveedor)
```

### Cambio en `ai-jobs`

`ai-jobs` actualmente **no tiene** mecanismo propio para llamar al modelo — el `trigger-ai-job.use-case.ts` solo encola el job en la DB. El worker (que no existe aún) necesitará un cliente de LM Studio. En lugar de crear esa conexión dentro de `ai-jobs`, importará `LlmProviderPort` desde `llm-gateway`.

**Resultado:** `ai-jobs` queda como orquestador; `llm-gateway` es el motor de inferencia.

---

## Estándar de la API adoptado para IA-DataFlow Hub

> Compatible con OpenAI SDK, LM Studio, y cualquier cliente que hable `/v1/chat/completions`.

### Base path

```
/v1/
```

Montado en `apps/api` — **no es un microservicio separado**.
(Separación a microservicio: fase futura cuando el volumen de inferencia lo justifique.)

### Autenticación

```
Authorization: Bearer <access_token_jwt>
```

Mismo JWT del resto de la API. Sin auth la ruta devuelve 401.

---

## Endpoints del estándar

### `POST /v1/chat/completions`

Inferencia de chat. Soporta respuesta completa y streaming SSE.

**Request body:**

```json
{
  "model": "lmstudio-community/meta-llama-3.1-8b-instruct",
  "messages": [
    { "role": "system",    "content": "Eres un asistente experto en ETL." },
    { "role": "user",      "content": "¿Cómo elimino duplicados en un dataset?" },
    { "role": "assistant", "content": "Puedes usar pandas.drop_duplicates()..." },
    { "role": "user",      "content": "Dame un ejemplo completo." }
  ],
  "stream": false,
  "temperature": 0.7,
  "max_tokens": 1024,
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0,
  "stop": null
}
```

| Campo | Tipo | Req | Default | Descripción |
|-------|------|-----|---------|-------------|
| `model` | string | ✓ | `LMS_DEFAULT_MODEL` | ID del modelo; si se omite usa el modelo por defecto |
| `messages` | array | ✓ | — | Historial. Roles válidos: `system`, `user`, `assistant` |
| `stream` | boolean | ✗ | `false` | `true` = respuesta SSE token a token |
| `temperature` | number | ✗ | `0.7` | Creatividad (0.0 – 2.0) |
| `max_tokens` | number | ✗ | `1024` | Tokens máximos a generar (`-1` = sin límite) |
| `top_p` | number | ✗ | `1.0` | Nucleus sampling |
| `frequency_penalty` | number | ✗ | `0.0` | Penaliza tokens frecuentes |
| `presence_penalty` | number | ✗ | `0.0` | Penaliza tokens ya en contexto |
| `stop` | string\|string[] | ✗ | `null` | Secuencias que detienen generación |

**Response — sin streaming (`stream: false`):**

```json
{
  "id": "chatcmpl-ia-dataflow-1748523600123",
  "object": "chat.completion",
  "created": 1748523600,
  "model": "lmstudio-community/meta-llama-3.1-8b-instruct",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Para eliminar duplicados en Python puedes usar..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 187,
    "total_tokens": 229
  }
}
```

**Response — con streaming (`stream: true`):**

`Content-Type: text/event-stream`. Formato SSE:

```
data: {"id":"chatcmpl-ia-dataflow-1748523600123","object":"chat.completion.chunk","created":1748523600,"model":"lmstudio-community/meta-llama-3.1-8b-instruct","choices":[{"index":0,"delta":{"role":"assistant","content":"Para"},"finish_reason":null}]}

data: {"id":"chatcmpl-ia-dataflow-1748523600123","object":"chat.completion.chunk","created":1748523600,"model":"lmstudio-community/meta-llama-3.1-8b-instruct","choices":[{"index":0,"delta":{"content":" eliminar"},"finish_reason":null}]}

data: {"id":"chatcmpl-ia-dataflow-1748523600123","object":"chat.completion.chunk","created":1748523600,"model":"lmstudio-community/meta-llama-3.1-8b-instruct","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

Reglas del stream:
- Primer chunk: `delta` incluye `"role":"assistant"` + primer token de `content`
- Chunks siguientes: solo `"content"` en `delta`
- Último chunk: `delta` vacío, `"finish_reason":"stop"` (o `"length"` si cortó por `max_tokens`)
- Stream termina con la línea literal `data: [DONE]`

---

### `GET /v1/models`

Lista modelos disponibles en el proveedor activo.

**Response:**

```json
{
  "object": "list",
  "data": [
    {
      "id": "lmstudio-community/meta-llama-3.1-8b-instruct",
      "object": "model",
      "created": 1748523600,
      "owned_by": "lmstudio"
    },
    {
      "id": "nomic-ai/nomic-embed-text-v1.5-GGUF",
      "object": "model",
      "created": 1748523600,
      "owned_by": "lmstudio"
    }
  ]
}
```

---

### Formato de errores

Todos los errores retornan este envelope (compatible OpenAI):

```json
{
  "error": {
    "message": "El campo 'messages' no puede estar vacío.",
    "type": "invalid_request_error",
    "code": "messages_required"
  }
}
```

| HTTP | `type` | Cuándo |
|------|--------|--------|
| 400 | `invalid_request_error` | Body inválido, campo faltante o mal formado |
| 401 | `authentication_error` | JWT ausente o expirado |
| 422 | `invalid_request_error` | `model` no encontrado en el proveedor |
| 429 | `rate_limit_error` | Usuario superó el límite de requests |
| 502 | `provider_error` | LM Studio u otro proveedor no responde |
| 500 | `server_error` | Error interno inesperado |

---

## Criterios de Aceptación

### Estructura del módulo
- El sistema debe crear `apps/api/src/modules/llm-gateway/` siguiendo Clean Architecture
- El sistema debe definir `LlmProviderPort` (interfaz de dominio) con métodos `chatCompletion()` y `listModels()`
- El sistema debe implementar `LmStudioProvider` en infraestructura como la implementación concreta de `LlmProviderPort`
- El sistema debe exportar `LlmProviderPort` para que `ai-jobs` pueda inyectarlo cuando el worker procese jobs

### Endpoints
- El sistema debe exponer `POST /v1/chat/completions` con `@ApiTags('LLM Gateway')`
- El sistema debe exponer `GET /v1/models` con `@ApiTags('LLM Gateway')`
- Ambos endpoints deben estar protegidos con `JwtAuthGuard`

### Conexión a LM Studio
- El sistema debe leer `LMS_BASE_URL` (default `http://localhost:1234`) de variables de entorno
- El sistema debe leer `LMS_API_KEY` para el header `Authorization: Bearer` en llamadas a LM Studio (vacío si sin auth)
- El sistema debe leer `LMS_DEFAULT_MODEL` para usar cuando `model` venga vacío en el request

### Streaming SSE
- El sistema debe retornar `Content-Type: text/event-stream` cuando `stream: true`
- El sistema debe hacer pipe del stream de LM Studio al cliente usando `Response` de NestJS con `res.write()`
- El sistema debe enviar `data: [DONE]\n\n` al finalizar
- El sistema debe cerrar el stream upstream si el cliente se desconecta

### Validación
- El sistema debe validar que `messages` no esté vacío y que cada elemento tenga `role` y `content`
- El sistema debe rechazar roles distintos de `system`, `user`, `assistant` con 400
- El sistema debe validar `temperature` en [0, 2] y `max_tokens >= -1`

### Rate limiting
- El sistema debe limitar a `LLM_RATE_LIMIT_RPM` requests/minuto por `userId` (default `30`)
- El sistema debe retornar HTTP 429 con campo `retry_after` en segundos al superarlo

### Logging de uso
- El sistema debe registrar por cada request completado: `userId`, `model`, `prompt_tokens`, `completion_tokens`, `latency_ms` en una tabla `llm_usage_logs` (nueva, a crear en migración)
- El sistema NO debe bloquear la respuesta al usuario para guardar el log (async/fire-and-forget)

### Swagger
- El sistema debe documentar ambos endpoints con `@ApiOperation`, `@ApiBody`, `@ApiResponse` incluyendo request/response bodies y el formato de error

### Integración con `ai-jobs`
- El sistema debe exportar `LlmGatewayModule` con `LlmProviderPort` disponible para inyección
- El sistema NO debe modificar `ai-jobs` en esta HU — la integración del worker con `LlmProviderPort` es trabajo futuro cuando se implemente el worker de procesamiento

---

## Variables de entorno requeridas

```env
LMS_BASE_URL=http://localhost:1234
LMS_API_KEY=                        # vacío si LM Studio corre sin auth local
LMS_DEFAULT_MODEL=lmstudio-community/meta-llama-3.1-8b-instruct
LLM_RATE_LIMIT_RPM=30
```

---

## Estructura de archivos esperada

```
apps/api/src/modules/llm-gateway/
├── llm-gateway.module.ts
├── domain/
│   └── ports/
│       └── llm-provider.port.ts        ← interfaz LlmProviderPort (exportada)
├── application/
│   ├── dtos/
│   │   ├── chat-completion-request.dto.ts
│   │   ├── chat-completion-response.dto.ts
│   │   └── models-list-response.dto.ts
│   └── use-cases/
│       ├── chat-completion.use-case.ts
│       └── list-models.use-case.ts
└── infrastructure/
    ├── controllers/
    │   └── llm-gateway.controller.ts
    └── providers/
        └── lmstudio.provider.ts        ← implementa LlmProviderPort
```
