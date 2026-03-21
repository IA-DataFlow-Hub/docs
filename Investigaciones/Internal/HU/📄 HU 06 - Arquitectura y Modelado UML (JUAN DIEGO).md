## 1. Arquitectura de N-Capas (Diseño Lógico)

Para este ecosistema, se propone una arquitectura de 4 capas que garantiza el desacoplamiento y la seguridad de los datos:

- **Capa de Presentación (Frontend):** Desarrollada en React, gestiona la interacción del usuario y la visualización de reportes de Power BI.
    
- **Capa de Orquestación y API (Backend):** NestJS actúa como el cerebro, gestionando la autenticación, los WebSockets y la comunicación con **n8n**.
    
- **Capa de Negocio e Inteligencia:** Aquí residen los Agentes de IA (Gemini/Llama 4) y los flujos de limpieza (OpenRefine/TOON).
    
- **Capa de Datos:** Repositorio central que almacena metadatos, versiones y perfiles de usuario.
    

---

## 2. Diagrama Entidad-Relación (DER)

El esquema de base de datos debe ser lo suficientemente flexible para manejar el versionamiento de los datos procesados.

- **Usuario:** ID, Nombre, Rol, Credenciales.
    
- **Proyecto:** ID, Nombre, Descripción, Fecha de Creación, ID_Usuario.
    
- **Carga_Dato:** ID, ID_Proyecto, Fuente (CSV/PDF/API), Fecha, Estado.
    
- **Versión_Procesada:** ID, ID_Carga, JSON_Resultado, Prompt_Utilizado (para trazabilidad de la IA).
    

---

## 3. Estándar JSON para Intercambio de Datos

Para que el Frontend de Oscar y el Backend de David hablen el mismo idioma, se define un contrato de datos estricto.

**Ejemplo de Metadatos extraídos por la IA:**

JSON

```
{
  "metadata": {
    "file_id": "IA-DF-001",
    "timestamp": "2026-03-21T09:15:00Z",
    "data_summary": {
      "rows_processed": 1500,
      "columns_detected": ["fecha", "ventas", "cliente"],
      "quality_score": 0.85
    },
    "ia_insights": "Se detectó una tendencia alcista en el segundo trimestre.",
    "toon_optimization": {
      "tokens_saved": 450,
      "efficiency_ratio": "1.2x"
    }
  }
}
```

---

## 4. Diagrama de Secuencia: Flujo de Limpieza de Datos

Este flujo describe cómo interactúan los componentes cuando un usuario carga datos "caóticos":

1. **Usuario** carga archivo en el **Frontend**.
    
2. **Backend (NestJS)** recibe el archivo y dispara un Webhook a **n8n**.
    
3. **n8n** envía el bloque de datos a **OpenRefine/IA** para limpieza.
    
4. La **IA** devuelve los datos estructurados bajo el estándar **TOON**.
    
5. **NestJS** guarda la nueva versión en la BD y notifica vía **WebSocket** al Frontend.
    
6. El **Frontend** actualiza el tablero de **Power BI**.
    

---

## 5. Reglas de Negocio (Extraídas del Documento Técnico)

Basado en los lineamientos de investigación de la CUN y el estándar del proyecto:

- **Seguridad:** Ningún dato sensible debe enviarse a la IA sin un proceso previo de anonimización en la capa de Backend.
    
- **Trazabilidad:** Cada respuesta de la IA debe estar vinculada a una versión específica del proyecto para permitir auditorías de datos.
    
- **Eficiencia:** Si el archivo supera los 5MB, el sistema debe activar obligatoriamente el procesamiento por hilos (Worker Threads) definido en la HU 03.