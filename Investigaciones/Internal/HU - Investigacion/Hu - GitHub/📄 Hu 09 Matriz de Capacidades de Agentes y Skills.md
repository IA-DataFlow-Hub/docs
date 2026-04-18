Para cumplir con la meta de centralizar, estructurar y automatizar la información, el flujo no debe depender de un solo modelo monolítico, sino de una **arquitectura multi-agente**. Usaremos n8n como orquestador para coordinar estos agentes y sus "Skills" (Function Calling).

|                           |                         |                                                                     |                                                                                               |
| ------------------------- | ----------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| **Rol del Agente**        | **Tipo de Agente**      | **Habilidades (Skills / Tool Use)**                                 | **Beneficio en IA-DataFlow**                                                                  |
| **Agente Orquestador**    | Supervisor / Router     | Evaluación de intenciones, enrutamiento condicional.                | Decide si un archivo requiere limpieza o si el usuario está haciendo una consulta analítica.  |
| **Agente de Limpieza**    | Ejecutor Determinístico | Detección de outliers, imputación de nulos, corrección semántica.   | Mejora la calidad de los datos en la fase de Ejecución BPM.                                   |
| **Agente Estandarizador** | Transformador           | Mapeo de JSON, tipificación de columnas, cálculo de quality_score.  | Asegura la transformación estricta al contrato TOON para interoperabilidad con React.         |
| **Agente Analista (RAG)** | Razonamiento Analítico  | Traducción de lenguaje natural a consultas sobre JSON estructurado. | Permite a los usuarios interactuar mediante un Chat Conversacional para la toma de decisiones |

**📋 Guía de Sintaxis de Comandos (Short-Prompts)**

Para reducir el consumo de tokens y acelerar la inferencia progresiva, implementaremos un sistema de comandos o "Short-Prompts". El backend interceptará estos comandos y los expandirá usando el prompt_hash almacenado en la tabla de versiones.

- **/clean:** Activa el "Few-shot Prompting" determinístico para identificar nulos y tipos de datos erróneos en el dataset crudo.
- **/toonify:** Fuerza al modelo (Gemini o Llama) a aplicar el esquema JSON estricto bajo el contrato TOON.
- **/anon:** Ejecuta el enmascaramiento de PII para cumplir con la Ley 1581 antes de que los datos pasen a modelos externos.
- **/chart [tipo]:** Instruye al modelo a parsear dimensiones y métricas del objeto TOON para configurar ejes en componentes UI de forma automática.
- **/ask [pregunta]:** Dispara la arquitectura RAG simplificada enviando los metadatos de la tabla como contexto para responder basadas solo en los datos.

**🔬 Reporte de Hallazgos y Feature Roadmap**

Identificamos el siguiente mapa de innovaciones para el núcleo de IA-DataFlow.

**Benchmark de Modelos para el Entorno:**

- **Llama (Local/Cuantizado):** Ideal para tareas de alta privacidad de datos (como el procesamiento inicial del dataset en bruto) y aislamiento en contenedores Docker.
- **Gemini (Vía API):** Superior en "Tool Use" (Function Calling) nativo, haciéndolo ideal para el Agente Analista (RAG) que debe interactuar fluidamente con el chat del usuario.

**Roadmap de Innovaciones Técnicas (Top 5):**

1. **Memoria de Sesión y Trazabilidad:** Uso del patrón de Snapshotting donde cada transformación guarda el prompt_hash y el JSON resultante, logrando un historial de cambios trazable.
2. **Autocorrección de Errores (Self-Healing):** Si el Agente Estandarizador falla al crear una estructura 100% compatible con los componentes UI, un agente validador lee el error_log y reescribe el output sin intervención humana.
3. **Extracción Multimodal Nativamente:** Aprovechar las capacidades multimodales modernas para extraer tablas directamente desde archivos PDF hacia Buffers, reemplazando librerías de parsing tradicionales.
4. **Generación Dinámica de UI (Generative UI):** Extender el mapeo dinámico de datos TOON para que la IA no solo devuelva un tablero visual, sino que sugiera el tipo de gráfico (ApexCharts) según la varianza de los datos.
5. **Streaming de Tokens con Feedback UI:** Acoplar el streaming de la IA con la arquitectura de eventos de Backend para actualizar la UI (Toast/Snackbar) mediante Socket.IO sin refrescar la página.