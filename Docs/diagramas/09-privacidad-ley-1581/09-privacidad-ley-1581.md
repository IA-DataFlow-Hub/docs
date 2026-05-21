# Diagrama 9 — Privacidad y Cumplimiento Ley 1581

**Qué muestra:** Cómo el sistema decide qué datos pueden salir a la nube y cuáles deben procesarse localmente, garantizando el cumplimiento de la Ley 1581 de protección de datos personales de Colombia.

**Última actualización:** 2026-05-12

---

## 9a — Flujo de decisión: local vs nube

```mermaid
flowchart TD
    START([📂 Usuario sube archivo\nCSV / Excel / JSON])
    START --> RECV[NestJS API recibe el archivo\nlo guarda en almacenamiento local]

    RECV --> DETECT[LM Studio analiza el archivo\nen busca de datos PII]

    DETECT --> DECISION{¿Contiene\ndatos PII?}

    DECISION -->|"Sí — nombres, cédulas,\ncorreos, teléfonos,\ndirecciones, etc."| LOCAL_PATH

    DECISION -->|"No — datos numéricos,\naggregados, públicos"| CLOUD_PATH

    subgraph LOCAL_PATH["🔒 Procesamiento LOCAL — LM Studio (host Windows)"]
        direction TB
        L1[LM Studio anonimiza los PII\nnombres → tokens únicos\ndocs → hashes seguros]
        L2[(Mapa de anonimización\nencriptado en DB local\nNO sale del servidor)]
        L3[Archivo sin PII\nlisto para procesamiento]
        L1 --> L2
        L1 --> L3
    end

    subgraph CLOUD_PATH["☁️ Procesamiento NUBE — Gemini 2.5 Flash-Lite"]
        direction TB
        C1[Datos comprimidos con TOON\nahorro ~45% de tokens]
        C2[Gemini analiza, limpia\ny estructura los datos]
        C3[Resultado procesado\ndevuelto al API]
        C1 --> C2 --> C3
    end

    LOCAL_PATH --> CLOUD_PATH
    CLOUD_PATH --> RESULT[API recibe resultado\nlo guarda en ai_results]

    RESULT --> RESTORE{¿El reporte necesita\ndatos originales?}

    RESTORE -->|"Sí — reporte interno\ncon datos reales"| REMAP[API reconstruye PII\nusando el mapa de anonimización]
    RESTORE -->|"No — reporte externo\no datos agregados"| FINAL_ANON[Entrega datos anonimizados]

    REMAP --> FINAL_REAL[📊 Reporte interno\ncon datos reales]
    FINAL_ANON --> FINAL_PUB[📊 Reporte externo\nsin datos personales]

    style LOCAL_PATH fill:#FED7D7,stroke:#E53E3E
    style CLOUD_PATH fill:#BEE3F8,stroke:#2B6CB0
    style L2 fill:#F6E05E,stroke:#D69E2E,color:#000
```

---

## 9b — Clasificación de datos PII vs seguros

```mermaid
graph LR
    subgraph PII["Datos PII — Solo procesamiento LOCAL"]
        P1["Nombres completos"]
        P2["Numeros de cedula o pasaporte"]
        P3["Correos electronicos"]
        P4["Numeros de telefono"]
        P5["Direcciones fisicas"]
        P6["Numeros de tarjeta o cuenta"]
        P7["Datos de salud"]
    end

    subgraph SAFE["Datos seguros — Pueden ir a la Nube"]
        S1["Cifras numericas y estadisticas"]
        S2["Fechas sin contexto personal"]
        S3["Categorias y etiquetas"]
        S4["Totales y agregados"]
        S5["Metricas de negocio"]
    end

    PII -->|anonimizar primero| SAFE
    SAFE -->|TOON compress| CLOUD(("Gemini"))

    style PII fill:#FED7D7,stroke:#E53E3E
    style SAFE fill:#C6F6D5,stroke:#276749
    style CLOUD fill:#BEE3F8,stroke:#2B6CB0
```

---

## 9c — Reglas de negocio (Ley 1581)

```mermaid
flowchart LR
    R1["Regla 1 — Ningun dato PII sin anonimizar puede salir del servidor"]
    R2["Regla 2 — El mapa de anonimizacion se guarda encriptado, nunca en logs"]
    R3["Regla 3 — El usuario debe dar consentimiento antes de subir datos PII"]
    R4["Regla 4 — Cada procesamiento queda en audit_logs con usuario y timestamp"]
    R5["Regla 5 — El usuario puede solicitar eliminacion de sus datos"]

    R1 & R2 & R3 & R4 & R5 --> COMPLIANCE["Cumplimiento Ley 1581 de 2012 Colombia"]

    style COMPLIANCE fill:#276749,color:#fff
```

---

## Notas de implementación

| Componente | Responsabilidad en la Ley 1581 |
|---|---|
| **LM Studio (local)** | Único que toca datos PII sin procesar; nunca expuesto a internet |
| **Mapa de anonimización** | Guardado en `configurations` table con cifrado AES-256 |
| **Gemini API** | Solo recibe datos ya anonimizados o no-PII |
| **audit_logs** | Registra toda operación con datos: quién, cuándo, qué archivo, qué IA |
| **Consentimiento** | Capturado en frontend antes del primer upload; guardado en `configurations` |

- La decisión de routing (local vs nube) la toma **LM Studio en la primera pasada** del archivo.
- Si LM Studio no está disponible, el sistema **bloquea el procesamiento** — nunca hace fallback a Gemini con datos PII sin revisar.
