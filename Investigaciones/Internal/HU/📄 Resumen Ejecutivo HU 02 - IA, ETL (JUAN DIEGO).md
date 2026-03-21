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


## 🏗️ Jerarquía de Control en IA Dataflow

Para que el procesamiento de 100k registros sea exitoso, cada nivel debe cumplir una función específica:

## 1. El Prompt (La Orden Operativa)

Es la unidad mínima de acción. Es el "qué" debe hacer la IA en este preciso segundo con un dato específico.

- **Ejemplo en tu proyecto:** "Toma esta lista de 100 filas y elimina los registros donde el correo electrónico sea idéntico. Devuelve solo los registros únicos en formato JSON".
    
- **Utilidad:** Es ejecución pura. Se usa en el nodo de Gemini o Llama 4 dentro de n8n para procesar el lote actual.
    

## 2. Instrucciones (El Manual de Procedimiento)

Es el "cómo" debe trabajar la IA siempre, independientemente del dato que reciba. Define las reglas de negocio y el comportamiento.

- **Ejemplo en tu proyecto:** "Para eliminar duplicados, prioriza siempre el registro que tenga la fecha de actualización más reciente. Si dos registros tienen el mismo ID pero distinto teléfono, marca ambos para revisión humana".
    
- **Utilidad:** Garantiza que la IA no tome decisiones arbitrarias y mantenga la integridad de tu base de datos PostgreSQL.
    

## 3. Skills / Habilidades (La Caja de Herramientas)

Es un entrenamiento o capacidad técnica específica que se le otorga a la IA para que pueda interactuar con el mundo exterior o realizar tareas técnicas.

- **Ejemplo en tu proyecto:** Una skill de **"Normalización de Direcciones"**. El agente sabe usar la API de Google Maps para convertir "Av. Siempre Viva 123" en una coordenada geográfica real.
    
- **Utilidad:** Permite que la IA haga cosas que un modelo de lenguaje por sí solo hace mal (como cálculos matemáticos exactos o validaciones de sintaxis de código).
    

## 4. Agentes (El Especialista)

Es la entidad superior. Un Agente es un rol que agrupa múltiples habilidades y sigue instrucciones complejas para cumplir un objetivo de alto nivel.

- **Ejemplo en tu proyecto:** **"Agente de Calidad de Datos (Data QA)"**.
    
    - **Instrucción:** Asegurar que los datos que llegan a Power BI sean perfectos.
        
    - **Skills:** SQL (para consultar la DB), Validación de JSON, Detección de anomalías.
        
- **Utilidad:** Los agentes pueden trabajar en cadena. Un agente limpia, otro anonimiza y un tercero audita.
    

---

## 📊 Comparativa de Roles en tu Arquitectura

|**Concepto**|**Representación**|**Aplicación en IA Dataflow**|
|---|---|---|
|**Prompt**|El Martillo|"Golpea este clavo (registro) ahora".|
|**Instrucción**|El Plano|"Los clavos deben ir cada 10cm y siempre rectos".|
|**Skill**|El Conocimiento|Saber usar un martillo neumático o una sierra láser.|
|**Agente**|El Carpintero|El profesional que sabe construir el mueble completo usando todo lo anterior.|

---

## 💡 ¿Cómo se ve esto en la práctica?

Si quieres organizar tus tablas de forma eficiente, podrías configurar un **Agente de Estructuración**:

1. **Instrucción:** "Eres un DBA (Administrador de Base de Datos). Tu objetivo es organizar tablas bajo la 3ra forma normal".
    
2. **Skill:** Capacidad de generar y ejecutar sentencias SQL en tu PostgreSQL.
    
3. **Prompt:** "Analiza estos datos de ventas y crea la tabla de 'Clientes' y la de 'Pedidos' vinculadas por un ID único".