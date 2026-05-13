# 📑 HU 07: Construcción del Corpus Maestro (150+ Archivos)

## 📝 Descripción
**Como** Líder de IA y Datos,  
**quiero** consolidar un repositorio de **150 archivos**  o más en formatos mixtos (CSV, JSON, XML, PDF, SQL, LOG),  
**para** someter a los agentes de IA a pruebas de estrés en limpieza, transformación y enriquecimiento, asegurando que el sistema **IA-DataFlow** sea resiliente ante datos del mundo real.

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

## ✅ Criterios de Aceptación (Definition of Done)
1. El inventario físico cuenta con un mínimo de **150 archivos**.
2. Cada archivo está clasificado y nombrado según la convención de categorías.
3. Se ha verificado manualmente que **no existe información sensible real** (PII) cumpliendo la Ley 1581.
4. El log de hallazgos en este repositorio registra la fuente y el tipo de error de cada archivo nuevo.