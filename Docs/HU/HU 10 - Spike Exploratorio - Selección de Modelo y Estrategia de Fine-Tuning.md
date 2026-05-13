**Como** Arquitecto de IA,  
**quiero** investigar y comparar las capacidades de los modelos Gemini frente a modelos locales (Llama 3.2),  
**para** definir el modelo base del sistema **IA-DataFlow** y establecer los requisitos técnicos, de infraestructura y de datos necesarios para su entrenamiento y optimización.

---

## 🔍 Objetivos de la Investigación (Ejes Centrales)

### 1. Selección del Modelo Base (The Engine)
* **Comparar:** Gemini 1.5 Flash vs. Gemini 1.5 Pro.
  * *Variables:* Ventana de contexto, costo por millón de tokens y velocidad de inferencia bajo el estándar TOON.
* **Evaluación Local:** Llama 3.2 (3B/8B) via Ollama.
  * *Variables:* Privacidad de datos (Ley 1581) y capacidad de procesamiento sin conexión a internet.

### 2. Estrategia de Entrenamiento (Optimización)
* **In-Context Learning (ICL):** Investigar cuántos ejemplos *Few-Shot* soporta el modelo antes de degradar el rendimiento.
* **Fine-Tuning (Ajuste Fino):** ¿Es necesario re-entrenar el modelo con datos de limpieza o basta con un Agent System?
* **RLHF (Reinforcement Learning):** Cómo usar el feedback del usuario en Power BI para "enseñar" a la IA sus errores.

### 3. Requisitos de Infraestructura
* **Cloud:** Cuotas de API en Google AI Studio y Vertex AI.
* **Local:** Requerimientos de VRAM (GPU) para ejecutar modelos cuantizados que soporten el volumen de datos de IA-DataFlow.

---

## 🛠️ Tareas de Investigación (Checklist)

- [ ] **Fase 1: Benchmark de Precisión:** Probar un set de "datos sucios" en Gemini y Llama para ver cuál detecta mejor errores complejos sin ayuda.
- [ ] **Fase 2: Requisitos de Datos de Entrenamiento:** Definir cuántos archivos "Clean Gold" necesitamos para que el modelo aprenda el estándar TOON (¿100, 500, 1000 pares de datos?).
- [ ] **Fase 3: Análisis de Costos:** Proyectar el gasto de procesar 150 archivos masivos mensualmente en la nube vs. el costo energético de un servidor local con GPU.
- [ ] **Fase 4: Seguridad y Cumplimiento:** Validar qué modelo garantiza mejor el cumplimiento de la Ley 1581 (Anonimización de datos sensibles).

---

## 📦 Entregables Requeridos (Outcome)

1. **📄 Decision Matrix (Matriz de Decisión):** Tabla comparativa final con el modelo ganador y la justificación técnica.
2. **📋 Data Blueprint para Entrenamiento:** Listado de los campos y estructuras necesarias para crear un dataset de entrenamiento (JSONL).
3. **📐 Stack Tecnológico Sugerido:** Definición de herramientas (Ollama, LangChain, Google AI SDK, etc.) para conectar el backend con el modelo elegido.

---

## ✅ Criterios de Aceptación (Definition of Done)
1. El reporte define claramente si se usará un modelo Cloud, Local o Híbrido.
2. Se detalla la cantidad mínima de datos necesarios para que el modelo sea "experto" en el estándar TOON.
3. Se presenta un presupuesto estimado de tokens/recursos para la fase de entrenamiento.
4. La investigación queda documentada y aprobada para iniciar la configuración del ambiente de inferencia.