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


```
Modelo: llama3.1:8b-int4 → ~6 GB RAM
RAG embeddings: nomic-embed-text → ~1 GB RAM
Vector DB (Chroma): → ~2 GB RAM
Sistema + overhead: → ~5 GB RAM
Total usado: ~14 GB ✅
```

## 📊 Escenarios Concurrentes (Llama 3.1 8B int4):

|Usuarios|Modelo Base|KV Cache por Usuario|VRAM/RAM Total Estimada|Resultado|
|---|---|---|---|---|
|**1-5**|6 GB|~0.2 GB c/u|7-8 GB|✅ Fluido|
|**10**|6 GB|~0.4 GB c/u|10 GB|✅ Lento|
|**30**|6 GB|~1 GB c/u|16 GB|⚠️ Límite, caídas|
|**50**|6 GB|~2 GB c/u|20+ GB|❌ OOM (Out of Memory)|
|**100**|6 GB|~4 GB c/u|30+ GB|❌ Falla total|
|**500-1000**|-|-|150-500 GB|❌ Imposible en tu servidor|

	┌─────────────┐     ┌──────────┐     ┌─────────────┐
	│   React UI  │────▶│ NestJS   │────▶│    n8n      │
	│             │◀────│ Gateway  │◀────│ Orquestador │
	└─────────────┘     └──────────┘     └─────────────┘
                                              │
                           ┌─────────────────────────┼─────────────────────────┐
                       ▼                         ▼                         ▼
	              ┌───────────┐            ┌───────────┐             ┌───────────┐
	              │ OpenRefine│            │  Llama 3.1│             │   MySQL   │
	              │ (Limpieza)│            │ (IA Agent)│             │ (Data DB) │
	              └───────────┘            └───────────┘             └───────────┘
	                │                         │                         │
	                ▼                         ▼                         ▼
	              ┌──────────┐            ┌───────────┐             ┌───────────┐
	              │  Redis   │◀───────────│ Queue     │◀────────────│ Power BI  │
	              │ (Cola)   │            │ System    │             │ (Dash)    │
	              └──────────┘            └───────────┘             └───────────┘


## 🛠️ Roles de n8n en tu Pipeline:

|Componente|Rol|Ejemplo de Workflow|
|---|---|---|
|**Trigger**|Recibe datos de NestJS|`HTTP Request` webhook|
|**IA Agent**|Llama 3.1 para análisis|`Ollama Node` → analiza datos|
|**Limpieza**|OpenRefine rules|`Execute Function` → GREL scripts|
|**Cola**|Envia a Redis queue|`Redis Set List` con prioridad|
|**Carga**|Guarda en MySQL|`MySQL Execute Query` INSERT|

## ⚙️ Configuración Recomendada:

|Componente|Configuración|RAM|
|---|---|---|
|**n8n**|Docker container|~500 MB|
|**Redis Queue**|Max clients=100|~200 MB|
|**Llama 3.1 8B**|int4 quantized|~6 GB|
|**OpenRefine**|Standalone server|~1-2 GB|
|**MySQL**|Innodb buffer pool|~2 GB|
|**NestJS Backend**|Production mode|~500 MB|
|**TOTAL**|-|**~11-12 GB** ✅|

