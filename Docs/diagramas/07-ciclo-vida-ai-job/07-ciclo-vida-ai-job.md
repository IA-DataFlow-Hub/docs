# Diagrama 7 — Cilo de vida ai job

**Qué muestra:** Todos los estados posibles de un job de IA y las transiciones entre ellos.`iadataflow_net`.

**Última actualización:** 2026-05-12

```mermaid
stateDiagram-v2
    %% Definición de estilos generales
    classDef mainflow fill:#f9f2f4,stroke:#d9534f,stroke-width:2px;
    classDef success fill:#e2f0d9,stroke:#5cb85c,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#d9534f,stroke-width:2px;

    %% Estado Inicial y Flujo Principal (Lineal en la imagen)
    [*] --> PENDING: [Sistema/Usuario] <br/> Job creado

    state "Flujo Principal" as main_flow {
        PENDING --> QUEUED: [Sistema] <br/> Encolado por planificador
        QUEUED --> PROCESSING: [n8n] <br/> Inicio de ejecución
        PROCESSING --> COMPLETED: [n8n] <br/> Finalización exitosa
    }

    %% Estado Final Exitoso
    COMPLETED --> [*]

    %% Agrupación para Manejo de Fallos y Cancelaciones
    state "Manejo de Fallos" as failure_handling {
        
        %% Transición de Falla desde PROCESSING
        PROCESSING --> FAILED: [n8n/Sistema] <br/> Error de ejecución o Timeout

        %% Bucle de Reintento (retry) - Muestra de FAILED a PROCESSING
        state Retrying {
            [*] --> FAILED
            FAILED --> PROCESSING: [Sistema/Usuario] <br/> (retry) <br/> Reintento automático o manual
        }

        %% Transiciones de Cancelación (Disparadas por el Usuario)
        QUEUED --> CANCELLED: [Usuario] <br/> Cancelar antes de procesar
        PROCESSING --> CANCELLED: [Usuario] <br/> Cancelar durante ejecución
        
        %% La imagen muestra FAILED -> CANCELLED
        FAILED --> CANCELLED: [Usuario] <br/> Cancelar trabajo fallido
    }

    %% Estado Final de Cancelación
    CANCELLED --> [*]

    %% Aplicación de estilos
    class PENDING,QUEUED,PROCESSING,main_flow mainflow
    class COMPLETED success
    class FAILED,CANCELLED,failure_handling,Retrying error
    ```