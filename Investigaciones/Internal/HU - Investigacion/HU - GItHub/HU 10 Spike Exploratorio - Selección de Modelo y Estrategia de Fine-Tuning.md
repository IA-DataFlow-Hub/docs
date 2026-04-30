
> [!ABSTRACT] Resumen del Proyecto
> 
> **IA-DataFlow** es un ecosistema inteligente diseñado para centralizar, limpiar y estructurar datos (Excel, JSON, SQL) de forma automática. El sistema utiliza una arquitectura híbrida: **IA Local** para privacidad y procesamiento de bajo costo, y **IA Cloud (Gemini)** para tareas de alta complejidad y contexto masivo.

---

## 🧠 1. Conceptos Fundamentales de IA

### 🤖 ¿Qué es una IA?

Es un sistema basado en **Redes Neuronales** capaz de procesar lenguaje natural mediante la predicción de tokens. En nuestro contexto, no solo "chatea", sino que actúa como un **Agente**: una entidad capaz de ejecutar código Python para manipular archivos y tomar decisiones lógicas.

### ⚙️ Fases de Entrenamiento

1. **Pre-entrenamiento:** La IA aprende conceptos generales (realizado por Google/Meta).
    
2. **Fine-Tuning (Ajuste Fino):** Se reentrena el modelo con ejemplos específicos de "Datos Sucios → Datos Limpios".
    
3. **RAG (Retrieval Augmented Generation):** Se le da acceso a una base de datos externa para que "consulte" antes de responder.
    
4. **Agentic Workflow:** Se le otorgan "herramientas" (ej. librerías de Excel) para que las use según la necesidad.
    

---

## 🛠️ 2. Estrategia de Modelos para el Proyecto

Para que el sistema sea capaz de recibir cualquier formato y estructurarlo, utilizaremos:

| **Modelo**                | **Tipo** | **Rol en IA-DataFlow**                                               |
| ------------------------- | -------- | -------------------------------------------------------------------- |
| **DeepSeek-R1 (Distill)** | 🏠 Local | Razonamiento lógico para detectar repetidos y datos faltantes.       |
| **Qwen2.5-Coder**         | 🏠 Local | Generación de scripts automáticos para ETL y transformación de JSON. |
| **Gemini 2.5 Pro**        | ☁️ Cloud | Análisis de archivos masivos y reportes ejecutivos finales.          |

---

## 💻 3. Evaluación de Infraestructura (Team IA)

> [!INFO] Estado de la Red
> 
> La prueba de conectividad mediante **ngrok** y **LM Studio** fue exitosa ✅. Esto permite que los nodos con menos hardware consuman la IA procesada en el nodo maestro.

### 🟢 Nivel: Servidor Maestro (High-End)

- **Juan Diego Mejía** * 💾 32 GB RAM | 🎮 RTX 5060 Ti 16GB
    
    - **Capacidad:** Puede entrenar (Fine-Tuning) modelos Llama-3 de 8B parámetros y correr modelos de hasta 14B-20B con fluidez.
        

### 🟡 Nivel: Soporte Operativo

- **Sebastián Bautista** (32 GB RAM | RTX 4050)
    
- **Andrés Andrade** (24 GB RAM | GTX 1650)
    
    - **Capacidad:** Ejecución de agentes locales y validación de outputs.
        

### 🔴 Nivel: Consumidores de API

- **Oscar, David, María, Pohlman** (8GB - 16GB RAM | Sin GPU)
    
    - **Rol:** Desarrollo de UI/UX, QA y consumo del backend procesado por Juan y Sebastián vía ngrok.
        

---

## 🔗 4. Fuentes Reales y Referencias

### 📺 Tutoriales y Guías Técnicas

- **Cómo crear agentes de datos (n8n + IA):** [https://www.youtube.com/watch?v=AJfd-eVf5eU](https://www.youtube.com/watch?v=AJfd-eVf5eU)
    
- **Entrenamiento local UnSlot :** 
   https://www.youtube.com/@HolaMundoDev/videos
   https://www.youtube.com/@nichonauta/videos
   https://www.youtube.com/@NullSafeArchitect/videos
   https://www.youtube.com/watch?v=xMm66CnUVgw
   https://www.youtube.com/watch?v=uzTPyCEX_C0
   https://www.youtube.com/@AlexOtano/videos
   https://www.youtube.com/watch?v=d9LGtygWEKQ
   https://www.youtube.com/watch?v=FFjvZV05vxM
   

Ingles
https://www.youtube.com/@NVIDIADeveloper/videos
   https://www.youtube.com/@PromptEngineer48/videos
   https://www.youtube.com/@DavidOndrej/videos
   https://www.youtube.com/watch?v=7gXB0wnCvLY
   https://www.youtube.com/@amplifyabhi/videos
   https://www.youtube.com/watch?v=Wjrdr0NU4Sk&t=158s
   https://www.youtube.com/@NetworkChuck/videos
   https://www.youtube.com/watch?v=syH-T9OSMqk
   https://www.youtube.com/@decodo_official/videos
   https://www.youtube.com/watch?v=rp5EwOogWEw
   https://www.youtube.com/@zenvanriel/videos
   https://www.youtube.com/watch?v=pxhkDaKzBaY
   https://www.youtube.com/@warpdotdev/videos
   https://www.youtube.com/watch?v=QKdKcFjjZhE
   https://www.youtube.com/watch?v=WzhPd4mVCJE
   https://www.youtube.com/@NetworkCoder/videos
   https://www.youtube.com/@TechWithTim/videos
   
- **Uso de LM Studio como Servidor API:** [https://www.youtube.com/watch?v=Zp80m7V9oE0](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DZp80m7V9oE0)
    https://www.youtube.com/watch?v=oVlVUCdTLlg

### 📖 Documentación y Artículos

- **Google Cloud - Fine-Tuning de Gemini:** [https://cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning](https://cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning)
    
- **IBM - RAG vs Fine-tuning:** [https://www.ibm.com/think/topics/rag-vs-fine-tuning](https://www.ibm.com/think/topics/rag-vs-fine-tuning)
    
- **DeepSeek-V3 Technical Report:** [https://github.com/deepseek-ai/DeepSeek-V3](https://github.com/deepseek-ai/DeepSeek-V3)
    

---

## 📈 5. Hoja de Ruta (Next Steps)

1. **Configurar Agentes:** En lugar de solo entrenar, usaremos **Herramientas (Tools)** para que la IA llame a funciones de limpieza.
    
2. **Pipeline de Datos:** * `Input (Excel/JSON) -> Agente Local (Detección de errores) -> Agente Gemini (Estructuración) -> Output (Reporte)`.
    
3. **Escalado:** Juan Diego expone el endpoint de **LM Studio** por ngrok para que todo el equipo trabaje sobre el mismo cerebro local.
    

---
# 🏗️ Guía Técnica: Cómo Entrenar tu Propia IA (Fine-Tuning Local)

### 1. ¿Qué datos necesitas en cada fase de entrenamiento?

|**Fase**|**Datos Necesarios**|**Formato / Requisito**|
|---|---|---|
|**Recolección**|Pares de `Input` (Datos Sucios) y `Output` (JSON estructurado).|Al menos 500 a 1,000 ejemplos para calidad mínima.|
|**Formateo**|Un archivo de texto donde se use un "Template".|Formato `.JSONL` (JSON Lines).|
|**Validación**|Un set de datos que la IA "no haya visto" durante el entrenamiento.|10% de tus datos totales.|

**Ejemplo de dato para IA-DataFlow:**

JSON

```
{"instruction": "Limpia y estructura los datos.", "input": "id: 1, nombre: Juan, fecha: 2024-01-01; id:1, nombre: Juan...", "output": "[{\"id\": 1, \"nombre\": \"Juan\", \"fecha\": \"2024-01-01\"}]"}
```

---

### 2. Software Detallado para el Entrenamiento

Para hacerlo en tu máquina con **32GB de RAM y 16GB de VRAM**, este es el kit de herramientas:

1. **Unsloth (Recomendado):** Es la librería más rápida y que menos memoria consume para entrenar modelos como Llama-3 o Mistral. Reduce el uso de VRAM en un 70%.
    
    - _Link:_ [Unsloth GitHub](https://github.com/unslothai/unsloth)
        
2. **Axolotl:** Una herramienta de línea de comandos que facilita el entrenamiento mediante archivos de configuración `.yaml`.
    
3. **Hugging Face TRL:** Para el entrenamiento de refuerzo.
    
4. **Google Colab (Opcional):** Si quieres dejar tu PC libre mientras entrenas, puedes usar sus GPUs gratis/pago.
    
5. **Weights & Biases (W&B):** Para ver las gráficas de cómo va aprendiendo tu IA y si se está "equivocando".
    

---

### 3. Fases Detalladas del Entrenamiento Local

1. **Tokenización:** Convertir tus Excels y JSONs en números que la IA entienda.
    
2. **Configuración de Hiperparámetros:** Decidir qué tan rápido aprende (`Learning Rate`) y cuánta memoria usará (`Batch Size`).
    
3. **Entrenamiento (The Run):** Aquí tu GPU trabajará al 100%. Con tu 5060 Ti, un entrenamiento de este tipo puede tardar de **2 a 6 horas**.
    
4. **Cuantización (GGUF):** Una vez entrenada, conviertes el modelo a formato `.GGUF` para poder usarlo en **LM Studio**.
    

---

### 📺 Videos Recomendados para Entrenar tu Propia IA

Aquí tienes fuentes reales y visuales para aprender el proceso paso a paso:

- **Fine-Tuning con Unsloth (El más fácil y rápido):**
    
    - [Ver video: Mistral/Llama Fine-Tuning with Unsloth](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DVgpLRE58e_I)
        
- **Entrenar IA con tus propios documentos (Guía completa):**
    
    - [Ver video: How to Fine-Tune LLMs on your own data](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DLslC2625pWc)
        
- **Conceptos de Fine-Tuning vs RAG (Cuándo hacer qué):**
    
    - [Ver video: Fine-tuning vs RAG - Which one to use?](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DtIBe669O_Y4)
        

---

### 💡 Nota para el modelo de Gemini (Versión Paga)

Como mencionaste que quieres usar **Gemini Pro (Suscripción)**:

Google no te deja "reentrenar" el modelo base desde cero, pero ofrece **Google AI Studio Tuning**.

- **Software:** [Google AI Studio](https://aistudio.google.com/).
    
- **Proceso:** Subes tu CSV directamente a la plataforma, seleccionas "Create Tuned Model", y Google usa sus servidores para crear una versión de Gemini que habla exactamente como tú quieres para IA-DataFlow.
    

> [!TIP] Consejo de Arquitectura
> 
> Dado que eres analista, te sugiero que el **Fine-Tuning** lo uses solo para que la IA aprenda el **formato de salida**, y uses **RAG** para que la IA lea los **datos nuevos**. Entrenar una IA con datos que cambian todos los días (como contabilidad) es muy costoso; es mejor que aprenda a "leer" y "limpiar" una vez, y luego solo le pases los archivos.


#ia-dataflow #software-architecture #ai-agents #local-llm