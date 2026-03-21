**Fecha:** 10 de marzo de 2026
**Responsables:** Juan Diego Mejía 
**Estado:** Análisis de Rentabilidad y Herramientas

## 🛠️ Glosario de Tecnologías Core

Para entender la eficiencia de este proyecto, es fundamental definir las tres tecnologías que permiten el procesamiento masivo con bajo presupuesto:

## 1. n8n (El Orquestador)

**n8n** es una herramienta de automatización de flujos de trabajo de código abierto (self-hosted).

- **Su función:** Actúa como el "cerebro" o director de orquesta. Es el encargado de recibir los 100,000 registros, decidir qué IA debe procesarlos y finalmente guardarlos en la base de datos.
    
- **Por qué se usa:** A diferencia de otras herramientas como Zapier, al instalarlo en tu propio servidor no pagas por cada registro procesado, lo que reduce el costo operativo de cientos de dólares a **$0**.
    

## 2. Llama 4 (La IA Privada y Local)

**Llama 4** es un modelo de lenguaje de gran tamaño (LLM) desarrollado por Meta, diseñado para ser ejecutado de forma local.

- **Su función:** Actúa como la "IA Guardiana". Se encarga exclusivamente de procesar los datos sensibles (nombres, teléfonos, documentos).
    
- **Por qué se usa:** Al correr dentro de tu propio servidor (vía **Ollama**), los datos confidenciales nunca viajan por internet ni pasan por servidores de terceros. Esto garantiza privacidad absoluta y un costo de **$0 por token**.
    

## 3. Google Gemini (La IA de Gran Escala)

**Gemini** es la familia de modelos de IA más avanzados de Google, conocida por su capacidad de procesar volúmenes masivos de información.

- **Su función:** Actúa como la "IA de Volumen". En su versión **2.5 Flash-Lite**, se encarga de la limpieza pesada, la normalización de texto y la detección de duplicados en todo el conjunto de datos.
    
- **Por qué se usa:** Su "ventana de contexto" (capacidad de memoria) de 1 millón de tokens le permite analizar miles de filas al mismo tiempo, algo que otras IAs no pueden hacer. Es la opción más económica y veloz del mercado en la nube para procesamiento masivo.

## 1. Resumen Ejecutivo: Proyecto IA Dataflow

El proyecto **IA Dataflow** implementa una arquitectura híbrida de vanguardia para procesar **100,000 registros**, priorizando la soberanía de datos y la eficiencia económica extrema mediante el uso coordinado de IA en la nube y local.

## 1.1. Ecosistema de IA Seleccionado

Basado en la documentación técnica de marzo de 2026, hemos asignado roles específicos a cada modelo:

- **IA de Volumen (Gemini 2.5 Flash-Lite):** * _Función:_ Limpieza estructural y deduplicación masiva.
    
    - _Ventaja:_ Ventana de contexto de 1M de tokens y el costo más bajo del mercado. Ideal para comparar la fila 10 con la 90,000.
        
- **IA Guardiana (Llama 4 - 8B Local):** * _Función:_ Anonimización de datos sensibles (PII).
    
    - _Ventaja:_ Ejecución 100% local en VPS (Costo $0 por token). Privacidad absoluta.
        
- **IAs de Comparativa (Backup):**
    
    - _GPT-4o mini:_ Para validaciones rápidas de formato.
        
    - _Claude 3.5 Haiku:_ Para casos de ambigüedad semántica compleja.
        

---

## 2. Desglose de Costos (Marzo 2026)

_Cálculo para 100k registros aplicando Tarifa Batch (50% desc.) y compresión TOON._

|**Proveedor**|**Modelo**|**Entrada (1M)**|**Salida (1M)**|**Costo 100k Reg.**|**Estatus**|
|---|---|---|---|---|---|
|**Google**|**Gemini 2.5 Flash-Lite**|**$0.05**|**$0.20**|**$11.25 USD**|**SELECCIONADA**|
|**Meta**|**Llama 4 (Ollama)**|**$0.00**|**$0.00**|**$0.00 USD**|**SELECCIONADA**|
|OpenAI|GPT-4o mini|$0.075|$0.30|$15.00 USD|Alternativa|
|Google|Gemini 3.1 Flash-Lite|$0.125|$0.75|$31.25 USD|Descartada|
|Anthropic|Claude 3.5 Haiku|$0.40|$2.00|$90.00 USD|Descartada|

---

## 3. Arquitectura e Infraestructura

Para orquestar este flujo, se utilizan herramientas que eliminan costos por ejecución y maximizan el control.

## Componentes Clave

- **n8n Self-Hosted:** El "Cerebro Operativo". Conecta archivos, IAs y bases de datos sin costo por tarea.
    
- **Estándar TOON:** Algoritmo de compresión de texto que ahorra hasta un 45% en el gasto de tokens.
    
- **VPS (Servidor Dedicado):** Aloja n8n, PostgreSQL y Llama 4 por un costo fijo de **$15 USD/mes**.
    

## Flujo Técnico Paso a Paso

1. **Ingesta:** n8n recibe los datos crudos vía Webhook o archivo.
    
2. **Filtro Local (Llama 4):** Se enmascaran datos sensibles para cumplir con normativas de privacidad.
    
3. **Compresión (TOON):** Se reduce el volumen de texto antes de enviarlo a la nube.
    
4. **Limpieza Masiva (Gemini):** Normalización y eliminación de duplicados globales.
    
5. **Carga:** Inserción en bloque (Bulk Insert) en **PostgreSQL**.
    

---

## 4. Diferencias Técnicas: Nube vs. Local

|**Característica**|**Google Gemini (Nube)**|**Llama 4 + Ollama (Local)**|
|---|---|---|
|**API Key**|Requerida (Facturación)|No necesaria|
|**Costo**|Pago por uso (tokens)|Gratis (Consumo de VPS)|
|**Privacidad**|Datos viajan a Google|Datos nunca salen del servidor|
|**Conexión en n8n**|Nodo Gemini + API Key|Nodo Ollama + URL Local|

> **Nota Técnica:** Para activar Llama 4 en el servidor, se utiliza el comando terminal `ollama pull llama4:8b`, permitiendo que n8n lo reconozca automáticamente.

---

## 5. Estrategias de Optimización Avanzada

1. **Bulk Insert (PostgreSQL):** En lugar de 100,000 operaciones de guardado, se agrupan en bloques de 5,000 para reducir el tiempo de 10 minutos a 30 segundos.
    
2. **Context Caching:** Gemini permite "congelar" instrucciones de limpieza pesadas para no pagar por ellas en cada petición.
    
3. **Split In Batches (n8n):** Divide el proceso en mini-lotes para evitar que la memoria RAM de 4GB colapse.
    
4. **Idempotencia (Upsert):** Uso de la función "Insert or Update" para evitar duplicados si el proceso debe reiniciarse tras un fallo.
    

---

## 6. Validación y Enlaces Oficiales

- [Tarifas Gemini 2.5 Flash-Lite](https://ai.google.dev/pricing)
    
- [Documentación Batch API (50% desc.)](https://ai.google.dev/gemini-api/docs/batch-api)
    
- [Precios OpenAI](https://openai.com/api/pricing)
- **Anthropic Pricing:** [anthropic.com/pricing](https://www.anthropic.com/pricing)


## 🛠️ Desglose Técnico: Personalización de la IA

Para transformar un modelo de lenguaje genérico en un **Obrero Especializado de Datos**, aplicamos los siguientes niveles de configuración:

## 1. El Prompt (La Orden Inmediata)

Es la instrucción específica que se envía en cada petición (request).

- **En IA Dataflow:** Se usa para pasar los datos crudos y decirle a la IA exactamente qué hacer con ese lote de registros.
    
- **Utilidad:** Permite cambiar la tarea sobre la marcha (ej. "Traduce estos 100 nombres" vs "Limpia estos 100 nombres"). Es la capa más volátil y flexible.
    

## 2. Instrucciones de Sistema (System Instructions / Persona)

Es el "ADN" del modelo. Se definen antes de que el modelo reciba los datos y no cambian durante la sesión.

- **En IA Dataflow:** Aquí configuramos que la IA actúe como un **"Ingeniero de Datos Senior"**.
    
- **Instrucción Clave:** _"Eres un experto en limpieza de datos. Tu salida debe ser estrictamente JSON. No pidas disculpas, no des explicaciones, solo entrega el código corregido."_
    
- **Utilidad:** Reduce las "alucinaciones" y asegura que la IA no intente conversar con el sistema, lo cual rompería el flujo de n8n.
    

## 3. Skills (Habilidades / Tool Use)

Son capacidades externas que la IA puede invocar cuando su conocimiento base no es suficiente.

- **En IA Dataflow:** Si la IA detecta una fecha en formato extraño (ej. "El jueves pasado"), puede llamar a una **Skill de Python** para convertirla a formato ISO `YYYY-MM-DD`.
    
- **Utilidad:** Permite que la IA realice cálculos matemáticos exactos o validaciones de reglas de negocio que los modelos de lenguaje suelen fallar por naturaleza probabilística.
    

## 4. Agentes (Autonomía y Toma de Decisiones)

Un agente es una IA que tiene un objetivo, no solo una tarea. Puede razonar: _"Si el dato está incompleto, voy a buscar en la base de datos de referencia antes de marcarlo como error"_.

- **En IA Dataflow:** Implementamos un **Agente de Calidad (QA Agent)** que revisa el trabajo de Gemini. Si Gemini comete un error de formato, el Agente detecta el error y le pide a Gemini que lo corrija antes de enviarlo a PostgreSQL.
    
- **Utilidad:** Crea un sistema de "auto-corrección" que permite procesar 100,000 registros sin supervisión humana constante.
    

---

## 📊 Cuadro de Utilidad en el Flujo ETL

|**Componente**|**¿Cuándo se aplica?**|**Impacto en el Proyecto**|
|---|---|---|
|**Prompt**|En cada lote de registros.|Precisión en la ejecución inmediata.|
|**Instrucciones**|Al inicio del flujo n8n.|Consistencia del formato (JSON) y tono profesional.|
|**Skills**|Cuando hay datos complejos.|Veracidad técnica (Cálculos, fechas, IDs).|
|**Agentes**|En el cierre de cada ciclo.|Autonomía total; reduce el error humano al 0%.|

---

## 💡 Ejemplo de Configuración para tu Proyecto

Si estuviéramos configurando el nodo de **Gemini 2.5 Flash-Lite** en n8n, el esquema sería:

- **Instrucción de Sistema:** "Eres el motor de limpieza de IA Dataflow. Ignora etiquetas HTML, corrige mayúsculas y entrega JSON puro."
    
- **Prompt:** "Procesa estos 50 registros de la columna 'Dirección': [Datos...]"
    
- **Skill:** Acceso a la API de Google Maps para validar si las direcciones existen.
    
- **Agente:** Un loop en n8n que verifica si el JSON es válido; si no, re-intenta el proceso.