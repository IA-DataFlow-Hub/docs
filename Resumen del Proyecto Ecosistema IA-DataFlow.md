## 🏗️ Resumen del Proyecto: Ecosistema IA-DataFlow

El proyecto busca democratizar la analítica de datos mediante la creación de un sistema **ETL (Extracción, Transformación y Carga) inteligente**. El objetivo principal es que cualquier usuario pueda subir datos "sucios" o desordenados y, mediante agentes de Inteligencia Artificial, obtener información estructurada y tableros visuales de alto valor sin necesidad de ser un experto en datos.

### 🎯 ¿Qué se quiere hacer? (Objetivos Clave)

1. **Automatizar el Caos:** Crear un flujo donde archivos CSV o Excel desordenados sean limpiados automáticamente usando **OpenRefine** y modelos de lenguaje (LLMs).
    
2. **Eficiencia y Ahorro:** Implementar el estándar **TOON** para que la comunicación con la IA sea más barata (ahorro de tokens) y precisa.
    
3. **Privacidad Local:** Garantizar que los datos sensibles se procesen dentro de la infraestructura propia mediante **Llama 4** (vía Ollama), cumpliendo estrictamente con la **Ley 1581**.
    
4. **Visualización Estratégica:** Integrar los resultados directamente en **Power BI** para que la toma de decisiones sea inmediata y visual.
    

---

### ⚙️ El Flujo de Trabajo (Pipeline Técnico)

El sistema operará bajo una arquitectura de N-capas integrada de la siguiente forma:

- **Entrada:** El usuario carga un archivo en una interfaz desarrollada en **React**.
    
- **Procesamiento (El "Cerebro"):** Un backend en **NestJS** orquestado con **n8n** divide el trabajo. Si los datos son sensibles, se envían a la IA local; si son generales, a modelos como Gemini.
    
- **Refinado:** Se aplican reglas de negocio y limpieza profunda (GREL) para eliminar duplicados e inconsistencias.
    
- **Salida:** Los datos limpios se inyectan en una base de datos **MySQL/SQL Server** y se visualizan en dashboards dinámicos.
    

---

### 👥 Distribución de "Superpoderes" (El Equipo)

Para lograr esto, el **FUUA Team** se divide en tres frentes críticos:

|**Frente**|**Responsables Clave**|**Misión**|
|---|---|---|
|**Arquitectura y Dev**|Juan Diego, David, Oscar, Brayan|Construir el core en .NET/NestJS y la interfaz en React/Angular.|
|**Infraestructura**|Sebastián, Andrés|Asegurar que los servidores, Docker y las BD soporten el procesamiento masivo.|
|**Seguridad y Soporte**|Pohlman, María Virginia|Garantizar el cumplimiento legal (Ley 1581) y la estabilidad de los endpoints.|

---

### 🚀 El Valor Diferencial

A diferencia de un ETL tradicional, **IA-DataFlow** no solo mueve datos, sino que los **entiende**. Gracias a la inyección de "reglas de negocio" en los prompts de la IA, el sistema puede detectar anomalías que un software convencional ignoraría, actuando como un consultor de datos automático.