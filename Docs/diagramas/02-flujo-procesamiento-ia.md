# Diagrama 2 — Flujo de Procesamiento de un Archivo con IA

**Qué muestra:** El recorrido completo desde que el usuario sube un archivo CSV hasta que recibe el resultado procesado por IA en pantalla.

**Última actualización:** 2026-05-12

---

```mermaid
sequenceDiagram
    actor U as 👤 Usuario
    participant FE as React Frontend
    participant API as NestJS API
    participant DB as MySQL
    participant N8N as n8n Orquestador
    participant LM as LM Studio (IA Local)
    participant GEM as Gemini (IA Nube)

    U->>FE: Selecciona y sube archivo CSV
    FE->>API: POST /api/files/upload (multipart)
    API->>DB: Guarda metadatos del archivo (files)
    API->>DB: Crea registro ai_job (estado: PENDING)
    API-->>FE: 200 OK — { fileId, jobId }
    FE-->>U: "Archivo recibido, procesando..."

    API->>N8N: POST webhook /process-file { fileId, jobId }
    API->>DB: Actualiza ai_job → QUEUED

    activate N8N
    N8N->>DB: Actualiza ai_job → PROCESSING

    N8N->>LM: Envía archivo para análisis
    alt LM Studio disponible
        LM-->>N8N: Resultado del análisis (insights, errores)
    else LM Studio no responde (fallback)
        N8N->>GEM: Envía datos a Gemini
        GEM-->>N8N: Resultado del análisis
    end

    N8N->>DB: Guarda resultado en ai_results
    N8N->>DB: Registra eventos en ai_job_events
    N8N->>DB: Actualiza ai_job → COMPLETED
    deactivate N8N

    N8N-->>API: Callback: job completado { jobId, resultId }
    API-->>FE: WebSocket: "job:completed" { jobId, resultId }
    FE->>API: GET /api/ai-jobs/:jobId/result
    API-->>FE: Datos del resultado procesado
    FE-->>U: Muestra resultados e insights en pantalla
```

---

## Flujo de estados del AI Job

```
PENDING → QUEUED → PROCESSING → COMPLETED
                       ↓
                     FAILED → (reintento automático) → PROCESSING
                       ↓
                   CANCELLED
```

## Notas

- El fallback a **Gemini** ocurre automáticamente si LM Studio no responde en el timeout configurado.
- El frontend se actualiza en tiempo real vía **WebSocket** (Socket.IO); no requiere polling.
- Todos los estados quedan registrados en `ai_job_events` para auditoría y trazabilidad.
- Los datos sensibles (PII) deben procesarse **únicamente** en LM Studio (local); nunca se envían a Gemini sin anonimización previa.
