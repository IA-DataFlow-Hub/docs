# Diagrama 10 — Flujo de Conversaciones y Chat con IA

**Qué muestra:** Cómo funciona el sistema de chat contextual: cómo el usuario interactúa con la IA dentro de un proyecto, cómo se mantiene el historial de mensajes, y cómo la IA usa el contexto del dataset activo para responder.

**Última actualización:** 2026-05-12

---

## 10a — Secuencia de un mensaje en el chat

```mermaid
sequenceDiagram
    actor U as 👤 Usuario
    participant FE as React Frontend
    participant API as NestJS API
    participant DB as MySQL
    participant LM as LM Studio
    participant GEM as Gemini

    U->>FE: Abre un proyecto y entra al chat
    FE->>API: GET /api/projects/:id/conversations
    API->>DB: Consulta conversaciones del proyecto
    DB-->>API: Lista de conversaciones
    API-->>FE: Conversaciones existentes
    FE-->>U: Muestra historial de chats

    U->>FE: Selecciona conversación o crea una nueva
    FE->>API: GET /api/conversations/:id/messages
    API->>DB: Consulta mensajes de la conversación
    DB-->>API: Historial de mensajes
    API-->>FE: Mensajes ordenados por created_at
    FE-->>U: Muestra el hilo de conversación

    U->>FE: Escribe y envía un mensaje
    FE->>API: POST /api/conversations/:id/messages
    API->>DB: Guarda mensaje del usuario
    API->>DB: Consulta los últimos 10 mensajes como contexto
    API->>DB: Consulta metadatos del dataset activo
    API->>API: Construye prompt con system prompt + dataset + historial
    API->>LM: POST /v1/chat/completions
    alt LM Studio disponible
        LM-->>API: Respuesta de la IA
    else LM Studio no responde
        API->>GEM: Solicitud a Gemini API
        GEM-->>API: Respuesta de la IA
    end

    API->>DB: Guarda respuesta como mensaje assistant
    API-->>FE: Respuesta de la IA via SSE o JSON
    FE-->>U: Muestra la respuesta en el chat
```

---

## 10b — Estructura del prompt enviado a la IA

```mermaid
graph TD
    subgraph PROMPT["Prompt construido por el API"]
        SP["System Prompt del proyecto — configurable por usuario"]
        DS["Contexto del Dataset — columnas, tipos, muestra de 5 filas, quality_score"]
        HX["Historial reciente — ultimos 10 mensajes de la conversacion"]
        UM["Mensaje actual del usuario"]
    end

    SP --> BUILD["API construye messages[]"]
    DS --> BUILD
    HX --> BUILD
    UM --> BUILD
    BUILD --> LM["LM Studio — POST /v1/chat/completions"]

    style PROMPT fill:#EBF8FF,stroke:#2B6CB0
    style BUILD fill:#2D3748,color:#fff
```

---

## 10c — Modelo de datos de conversaciones

```mermaid
erDiagram
    projects {
        uuid id PK
        string name
    }

    conversations {
        uuid id PK
        uuid project_id FK
        uuid user_id FK
        string title
        datetime created_at
    }

    messages {
        uuid id PK
        uuid conversation_id FK
        string role
        text content
        datetime created_at
    }

    projects ||--o{ conversations : "tiene"
    conversations ||--o{ messages : "acumula"
```

---

## 10d — Ciclo de vida de una conversación

```mermaid
stateDiagram-v2
    [*] --> Nueva : Usuario crea conversacion desde un proyecto
    Nueva --> Activa : Usuario envia el primer mensaje
    Activa --> Activa : Intercambio de mensajes usuario e IA
    Activa --> Archivada : Usuario archiva la conversacion
    Archivada --> Activa : Usuario reactiva
    Activa --> Eliminada : Usuario elimina con soft delete
    Eliminada --> [*]
```

---

## Notas de implementación

| Aspecto | Detalle |
|---|---|
| **Contexto de mensajes** | Se envían los últimos **10 mensajes** para no exceder el context window del modelo |
| **System prompt** | Configurable por proyecto en `configurations` table con key `ai_system_prompt` |
| **Contexto del dataset** | Solo metadatos, no el CSV completo, para eficiencia de tokens |
| **Streaming** | El API puede devolver respuesta en **Server-Sent Events (SSE)** para efecto typewriter |
| **Fallback** | Si LM Studio falla, se usa Gemini solo si el dataset activo no tiene PII |
| **Eliminación** | Soft delete — los mensajes se marcan con `deleted_at`, no se borran físicamente |

- Cada conversación pertenece a un **proyecto**, no a un archivo específico.
- El `role` del mensaje sigue el estándar OpenAI: `"user"` / `"assistant"` / `"system"`.
