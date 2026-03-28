**Fecha:** 10 de marzo de 2026
**Responsables:** Juan Diego Mejía / Brayan Monterrosa
**Estado:** Análisis de Rentabilidad y Herramientas

## 1. Economía de Tokens (Costos por 1M de Tokens)

Se analizan los modelos con mejor desempeño en tareas de limpieza y estructuración de datos (ETL). Los precios están sujetos al nivel de uso (Tier 1).

|**Modelo**|**Entrada (Input)**|**Salida (Output)**|**Enlace de Referencia**|
|---|---|---|---|
|**GPT-4o**|$2.50 USD|$10.00 USD|[OpenAI Pricing](https://openai.com/api/pricing/)|
|**Claude 3.5 Sonnet**|$3.00 USD|$15.00 USD|[Anthropic Pricing](https://www.anthropic.com/pricing)|
|**Gemini 1.5 Flash**|$0.075 USD|$0.30 USD|[Google AI Pricing](https://ai.google.dev/pricing)|

> [!TIP]
> 
> **Gemini 1.5 Flash** es la opción más rentable para el procesamiento masivo de registros (100k), reduciendo costos en más de un 90% frente a GPT-4o sin sacrificar velocidad.

---

## 2. Herramientas de Orquestación y ETL

Para gestionar el flujo de datos sin bloquear el sistema, se han preseleccionado las siguientes herramientas:

- **n8n (Self-hosted):** Permite crear flujos visuales conectando el CSV/Excel con la API de IA. **Ventaja:** Sin costo de suscripción por ejecución si se aloja en el VPS de la HU 01. [Ver n8n](https://n8n.io/)
    
- **LangChain (Python/JS):** Librería técnica para manejar "cadenas" de limpieza. Ideal para procesos que requieren lógica compleja antes de enviar a la IA. [Ver LangChain](https://www.langchain.com/)
    

---

## 3. Proyección de Gasto (Estimado por Registros)

Calculado sobre un promedio de 500 tokens por registro (limpieza + normalización).

|**Volumen de Datos**|**Costo Est. Gemini Flash**|**Costo Est. GPT-4o**|
|---|---|---|
|**20,000 registros**|$1.50 USD|$62.50 USD|
|**50,000 registros**|$3.75 USD|$156.25 USD|
|**100,000 registros**|$7.50 USD|$312.50 USD|

---

## 4. Rate Limits y Restricciones

- **OpenAI:** Nivel gratuito limita a 3 RPM (Solicitudes por minuto). Para 100k registros se requiere **Tier 2** ($50 de prepago mínimo).
    
- **Google (Gemini):** El plan gratuito permite hasta 15 RPM, pero los datos se usan para entrenamiento. El **plan de pago** (Pay-as-you-go) protege la privacidad y escala según necesidad. [Ver Rate Limits](https://www.google.com/search?q=https://ai.google.dev/pricing%23limits)
    

---

## 5. Conclusión / Recomendación

Se recomienda el uso de **Gemini 1.5 Flash** orquestado mediante **n8n** alojado localmente. Esta combinación garantiza privacidad de datos corporativos, escalabilidad para 100,000 registros y un costo operativo extremadamente bajo para el prototipo.