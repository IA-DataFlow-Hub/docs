# HU-038 — Fine-Tuning y Preparación de Datasets de IA

## Historia de Usuario

**Como** equipo de desarrollo,  
**Quiero** preparar los datasets de entrenamiento y ejecutar el fine-tuning del modelo local,  
**Para** que Llama 4 responda de forma especializada en tareas de limpieza y análisis de datos tabulares en español.

---

## Contexto

El modelo Llama 4 base responde bien en general, pero no está optimizado para el contexto específico de IA-DataFlow: instrucciones en español sobre datos tabulares (CSV, Excel), terminología de ETL y respuestas estructuradas.

El fine-tuning ajusta el modelo con ejemplos reales del dominio para mejorar la calidad de las respuestas sin necesidad de prompts muy largos.

**Dependencia:** Los datasets de entrenamiento deben estar listos antes de ejecutar el fine-tuning. Esta HU cubre ambas fases: preparación y ejecución.

---

## Criterios de Aceptación

- [ ] Existen al menos 200 ejemplos de entrenamiento en formato correcto.
- [ ] Los ejemplos cubren las 4 tareas principales: limpieza, análisis, normalización y resumen.
- [ ] El modelo fine-tuneado responde correctamente en el 80% de las pruebas manuales.
- [ ] El modelo fine-tuneado está disponible en Ollama con un nombre propio (ej. `dataflow-llama`).
- [ ] El proceso de fine-tuning está documentado y es reproducible.
- [ ] Los datasets de entrenamiento están versionados en `ai-services/fine-tuning/datasets/`.

---

## Fase 1 — Preparación de Datasets

### Formato de cada ejemplo

Cada ejemplo de entrenamiento tiene tres partes:

```json
{
  "instruction": "Limpia este dataset eliminando filas duplicadas y estandarizando el formato de fechas.",
  "input": "nombre,fecha_nacimiento,ciudad\nJuan Pérez,01/03/1990,bogotá\njuan pérez,1990-03-01,Bogotá\nMaría López,15-07-1985,medellín",
  "output": "Se encontraron 2 filas duplicadas (Juan Pérez). Se eliminó la segunda. Se estandarizaron las fechas al formato YYYY-MM-DD. Se normalizaron las ciudades a capitalización estándar.\n\nnombre,fecha_nacimiento,ciudad\nJuan Pérez,1990-03-01,Bogotá\nMaría López,1985-07-15,Medellín"
}
```

### Categorías de ejemplos a preparar

| Categoría | Cantidad mínima | Descripción |
|-----------|-----------------|-------------|
| Limpieza de datos | 60 ejemplos | Duplicados, nulos, formatos incorrectos |
| Análisis de estructura | 50 ejemplos | Descripción de columnas, tipos, anomalías |
| Normalización | 50 ejemplos | Fechas, nombres, categorías, unidades |
| Resumen ejecutivo | 40 ejemplos | Descripción en lenguaje natural del dataset |

### Fuentes para los ejemplos
- Datasets reales anonimizados del proyecto (los que está organizando el equipo).
- Datos sintéticos generados para cubrir casos borde.
- Ejemplos creados manualmente por el equipo.

### Reglas para los ejemplos
- Todo en español.
- Instrucciones variadas (no repetir el mismo enunciado).
- Los outputs deben ser precisos y verificados manualmente.
- No incluir datos personales reales.

---

## Fase 2 — Fine-Tuning

### Proceso

1. Convertir los ejemplos al formato `JSONL` requerido por la herramienta de fine-tuning.
2. Dividir en: 80% entrenamiento, 10% validación, 10% prueba.
3. Ejecutar fine-tuning usando **Ollama + Modelfile** o **llama.cpp** con LoRA.
4. Evaluar el modelo con el set de prueba.
5. Si el rendimiento es aceptable → publicar el modelo en Ollama.
6. Documentar los parámetros usados (epochs, learning rate, etc.).

### Comando de publicación en Ollama
```bash
ollama create dataflow-llama -f ./Modelfile
ollama run dataflow-llama "Analiza este dataset: ..."
```

---

## Estructura de Archivos

```
ai-services/fine-tuning/
├── datasets/
│   ├── limpieza/
│   │   ├── ejemplos-raw.json        ← ejemplos sin procesar
│   │   └── ejemplos-validados.json  ← revisados manualmente
│   ├── analisis/
│   ├── normalizacion/
│   └── resumen/
├── training/
│   ├── train.jsonl                  ← dataset final de entrenamiento
│   ├── val.jsonl
│   └── test.jsonl
├── Modelfile                        ← configuración del modelo fine-tuneado
├── evaluate.sh                      ← script para evaluar el modelo
└── README.md                        ← cómo reproducir el fine-tuning
```

---

## Tareas

### Preparación de datos
1. [ ] Definir y documentar el formato exacto de los ejemplos.
2. [ ] Recolectar y anonimizar datasets reales para usar como base.
3. [ ] Crear 60 ejemplos de limpieza de datos.
4. [ ] Crear 50 ejemplos de análisis de estructura.
5. [ ] Crear 50 ejemplos de normalización.
6. [ ] Crear 40 ejemplos de resumen ejecutivo.
7. [ ] Revisar y validar manualmente todos los ejemplos.
8. [ ] Convertir a formato `JSONL` y dividir en train/val/test.

### Fine-tuning
9. [ ] Configurar el entorno de fine-tuning (llama.cpp o equivalente).
10. [ ] Ejecutar primera ronda de entrenamiento.
11. [ ] Evaluar resultados con el set de prueba.
12. [ ] Ajustar parámetros si es necesario y repetir.
13. [ ] Publicar modelo final en Ollama como `dataflow-llama`.
14. [ ] Documentar el proceso en `README.md`.

---

## Dependencias

- **HU-033** — El entorno de Ollama debe estar instalado antes del fine-tuning.
- Los datasets que está organizando el equipo son la materia prima de los ejemplos.

## Prioridad

**Media** — El sistema funciona con el modelo base (Llama 4 sin fine-tuning) mientras esta HU se completa. El fine-tuning mejora la calidad pero no es bloqueante para el desarrollo.
