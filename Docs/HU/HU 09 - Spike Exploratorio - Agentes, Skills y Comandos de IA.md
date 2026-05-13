**Como** Arquitecto de IA,  
**quiero** investigar y mapear el ecosistema de agentes, habilidades (skills) y comandos personalizados compatibles con los modelos Gemini y Llama,  
**para** definir el potencial de automatización inteligente y las innovaciones técnicas que formarán el núcleo del sistema **IA-DataFlow**.

---

## 🔍 Objetivos de la Investigación (¿Qué estamos buscando?)

El equipo debe explorar y documentar el potencial de:

https://aimafia.substack.com/p/skills-ia
https://agentskills.io/client-implementation/adding-skills-support
https://github.com/agentskills/agentskills?tab=readme-ov-file

### 1. Agentes Especializados (Roles)
* **Investigar:** ¿Qué tipos de agentes autónomos existen? (Ej: Agentes de razonamiento, Agentes de herramientas, Agentes de supervisión).
* **Propuesta:** ¿Cómo dividir el flujo de datos entre agentes para que uno "piense" el plan y otro "ejecute" la limpieza?

### 2. Skills (Habilidades Dinámicas)
* **Investigar:** Concepto de *Tool Use* o *Function Calling* en Gemini. 
* **Propuesta:** ¿Qué habilidades específicas debería tener nuestra IA? (Ej: Detección automática de outliers, traducción de formatos, o generación de scripts SQL sobre la marcha).

### 3. Comandos Personalizados (Short-Prompts)
* **Investigar:** Cómo crear una sintaxis de comandos rápidos (ej: `/clean`, `/anon`, `/summary`) que la IA entienda como una instrucción de "macro" para ahorrar tokens.

---

## 🛠️ Tareas de Investigación (Checklist)

- [ ] **Fase 1: Estado del Arte:** Investigar cómo plataformas líderes manejan agentes (ej. CrewAI, LangChain o el Agent Builder de Google).
- [ ] **Fase 2: Catálogo de Innovaciones:** Identificar al menos 5 características innovadoras (ej: memoria a largo plazo entre sesiones, auto-corrección de errores, o razonamiento multi-paso).
- [ ] **Fase 3: Pruebas de Concepto (PoC):** Realizar pruebas rápidas en Gemini AI Studio usando comandos personalizados para ver si el modelo mantiene la consistencia.
- [ ] **Fase 4: Benchmark de Modelos:** ¿Cuál modelo responde mejor a "instrucciones por comandos"? (Comparar Gemini 1.5 Flash vs Llama 3.2).

---

## 📈 Beneficios Esperados
* **Entrenamiento:** Entender cómo estructurar los datos para que sirvan de base para entrenar un agente especializado.
* **Escalabilidad:** Identificar cómo el sistema puede aprender nuevas "skills" sin cambiar el código base.
* **Eficiencia:** Validar si el uso de comandos reduce significativamente el tamaño de los prompts maestros.

---

## 📦 Entregables Requeridos (Resultado de la Exploración)

1.  **📄 Matriz de Capacidades de Agentes:** Documento que compare roles sugeridos, sus habilidades necesarias y el beneficio directo para el usuario.
2.  **📋 Guía de Sintaxis de Comandos:** Propuesta inicial de comandos `/` y su equivalencia en instrucciones extensas (Mapeo TOON).
3.  **🔬 Reporte de Hallazgos y "Feature Roadmap":** Listado de innovaciones encontradas que podríamos implementar en fases futuras.

---

## ✅ Criterios de Aceptación (Definition of Done)
1. Se presenta una arquitectura conceptual clara de cómo interactuarían los agentes.
2. Se demuestra, mediante pruebas en el Playground, que la IA es capaz de ejecutar acciones basadas en comandos cortos.
3. Se entrega un análisis sobre cómo estas características facilitan el entrenamiento futuro del modelo.
4. Toda la investigación queda consolidada en el repositorio `/docs`.