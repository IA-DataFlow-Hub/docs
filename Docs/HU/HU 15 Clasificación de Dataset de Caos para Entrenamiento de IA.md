Como Ingeniero de IA, Quiero categorizar los 100+ archivos de prueba en un listado técnico, Para realizar un fine-tuning preciso del modelo.


Mover de https://github.com/IA-DataFlow-Hub/docs a https://github.com/IA-DataFlow-Hub/IA-DataFlow-Hub
 
Criterios de Aceptación:
**50 archivos por cada tipo de extension en  buscado y otros 50 por cada tipo en generado.**
o	Dataset dividido en categorías: Redundancia, Estructuras Rotas, Multi-pestaña, Tipos Inconsistentes.
o	Inclusión de "Casos de Caos Combinado" (ej: Archivo corrupto + Duplicados).
•	Tareas Técnicas:
o	12.1: Crear set de datos "Fuzzy Matching" para identificar duplicados no exactos.
o	12.2: Generar archivos con "Data Drift" (cambio repentino de formato en mitad del archivo).
o	12.3: Preparar archivos JSONL con pares (Input Caótico / Output Limpio) para el entrenamiento.

[![Ver video](https://img.youtube.com/vi/IeQqagGrm-I/hqdefault.jpg)](https://www.youtube.com/watch?v=IeQqagGrm-I)


---
## 🚀 Estrategia de Recolección (Dataset Hunting)


### 📺 Recurso de Apoyo: Entrenamiento en Búsqueda de Datos
mira este video antes de empezar la recolección para aprender a usar filtros avanzados:

[![Ver Tutorial de Búsqueda de Datos](https://img.youtube.com/vi/TSi_eCLJSIg/0.jpg)](https://www.youtube.com/watch?v=TSi_eCLJSIg)

> [!TIP]
> Haz clic en la imagen de arriba para abrir el video en YouTube.
## 🗂️ Categorías del Dataset (Distribución de Carga)

| Categoría de Caos | Cantidad | Propósito Técnico |
| :--- | :---: | :--- |
| **Redundancia Crítica** | 30 | Identificación de duplicados difusos (fuzzy matching). |
| **Estructuras Rotas** | 30 | Manejo de nulos, filas vacías y archivos mal formados. |
| **Multi-Entidad (Pestañas/Tablas)** | 30 | Unificación de múltiples tablas y pestañas en un solo esquema. |
| **Inconsistencia de Tipos** | 25 | Normalización de fechas, monedas y formatos regionales. |
| **Extracción No Estructurada** | 20 | Parsing de PDF y Logs para convertirlos en tablas. |
| **Optimización de Esquema** | 15 | Inferencia de tipos de datos correctos desde SQL Dumps. |

---

## 🛠️ Tareas de Ejecución (Checklist)

- [ ] **Fase 1: Generación Sintética (50 archivos):** Crear archivos con errores inducidos (duplicados, nulos, tablas mezcladas).
- [ ] **Fase 2: Recolección Real (100 archivos):** Descargar datasets de fuentes públicas y gubernamentales.
- [ ] **Fase 3: Clasificación:** Nombrar archivos bajo el estándar `CAT_TIPO_ID` (ej: `REDUNDANCIA_CSV_001.csv`).
- [ ] **Fase 4: Anonimización:** Aplicar filtros de seguridad para cumplir con la **Ley 1581**.

---

## 🚀 Estrategia de Recolección (Dataset Hunting)

> [!IMPORTANT]
> **No se trata de descargar por descargar.** El éxito de nuestra IA no depende de la cantidad, sino de la **complejidad** de los datos. Los enlaces proporcionados son solo el punto de partida; la excelencia del modelo depende de la capacidad de investigación del equipo para encontrar datos "imposibles".

### 🔗 Fuentes Base (Sugerencias Iniciales)
- **Generadores Sintéticos:**
  - [Mockaroo](https://www.mockaroo.com/)
  - [GenerateData V4](https://generatedata.com/generator)
  - [Faker Python Library](https://faker.readthedocs.io/en/master/)
  - *Uso: Crear errores específicos (edge cases) que no se encuentran fácilmente en repositorios limpios.*

- **Repositorios Reales:**
  - [Kaggle Datasets](https://www.kaggle.com/datasets)
  - [Datos Abiertos Colombia](https://www.datos.gov.co/)
  - [DataSetSearch google](https://datasetsearch.research.google.com/)
  - [Awesome Public Datasets](https://github.com/awesomedata/awesome-public-datasets)
  - *Uso: Capturar el desorden real de empresas y entidades gubernamentales.*

### 🔍 El Reto de Investigación (Deep Hunting)
Se espera que cada integrante investigue más allá de los links básicos:
1. **Datasets de Nicho:** Explorar repositorios universitarios, foros de DBAs o archivos públicos de transparencia poco conocidos.
2. **Casos de Borde (Edge Cases):** Buscar archivos que "rompan" sistemas: fechas en formatos inexistentes, caracteres especiales corruptos (encoding), o archivos sin delimitadores estándar.
3. **Formatos Especiales:** No limitarse a archivos planos. Buscar **SQL Dumps** reales de sistemas legados o **Logs de servidores** con estructuras anidadas complejas.

### 🤖 Recursos Específicos para Entrenamiento de IA 
- [OpenRefine Sample Data](https://github.com/OpenRefine/OpenRefine) - Casos de prueba de limpieza pre-diseñados.
- [VizNet](https://github.com/mitmedialab/viznet) - Corpus masivo de hojas de cálculo para entender estructuras visuales.

---
