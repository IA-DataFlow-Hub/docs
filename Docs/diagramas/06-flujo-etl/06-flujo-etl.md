# Diagrama 6 — Flujo etl

**Qué muestra:** Cómo un template ETL se aplica a un archivo paso a paso. `iadataflow_net`.

**Última actualización:** 2026-05-12

```mermaid
---
config:
  layout: elk
---
flowchart TD
    classDef frontend stroke:#f87171,fill:#fef2f2;
    classDef api stroke:#4ade80,fill:#f0fdf4;
    classDef n8n stroke:#facc15,fill:#fefce8;
    classDef db stroke:#22d3ee,fill:#ecfeff;
    classDef error stroke:#f87171,fill:#fef2f2;

    subgraph Frontend ["1. Frontend"]
        A(["Usuario selecciona template + archivo"]):::frontend
    end

    subgraph API ["2. API / Backend"]
        B["Crear registro de etl_execution"]:::api
        C["Enviar a n8n:<br/>{ file, steps[] }"]:::api
        H["Recibir archivo transformado"]:::api
        I["Guardar resultado como nuevo Dataset"]:::api
        J["Registrar Lineage:<br/>Original → Transformación → Resultado"]:::api
        K["Registrar error de ejecución"]:::api
    end

    subgraph N8N ["3. Motor ETL - n8n"]
        D["Iniciar procesamiento de pasos"]:::n8n
        E{"¿El paso actual<br/>pasó con éxito?"}:::n8n
        F["Avanzar al siguiente paso"]:::n8n
        Err(["Detener y reportar error"]):::error
        Succ(["Devolver archivo transformado"]):::n8n
    end

    subgraph Database ["4. Base de Datos / Almacenamiento"]
        DB_Fail[("Estado: Fallido<br/>+ Logs de Error")]:::db
        DB_Success[("Nuevo Dataset<br/>+ Lineage Guardado")]:::db
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E -->|"Sí, hay más pasos"| F
    F --> E
    E -->|"No, un paso falló"| Err
    Err -->|"Devuelve log de error"| K
    K --> DB_Fail
    E -->|"Sí, todos terminaron"| Succ
    Succ -->|"Devuelve archivo"| H
    H --> I
    I --> J
    J --> DB_Success
    ```