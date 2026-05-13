# HU-039 — Entrenamiento y Fine-Tuning de Modelos de IA

## Historia de Usuario

**Como** equipo de desarrollo,  
**Quiero** hacer fine-tuning de los modelos de IA locales con datos propios del dominio,  
**Para** que respondan de forma especializada en tareas de análisis, limpieza y procesamiento de datos tabulares en español, sin depender de prompts largos ni del cloud.

---

## Contexto

Los modelos base (DeepSeek V4 Flash, Llama 3, Qwen 2.5 14B) funcionan bien en general, pero no están optimizados para el dominio específico de IA-DataFlow: instrucciones en español sobre datos tabulares (CSV, Excel), terminología ETL y respuestas estructuradas.

El fine-tuning con **QLoRA** permite adaptar estos modelos usando la misma máquina de desarrollo (16 GB de RAM/VRAM) sin necesidad de infraestructura cloud ni GPUs de alto costo.

**Dependencia:** requiere que HU-033 esté completa (Ollama + modelos base instalados).

---

## Modelos a entrenar

| Modelo | Tamaño base | VRAM estimada (QLoRA) | Herramienta recomendada |
|--------|-------------|----------------------|------------------------|
| `llama3:8b` | 8B params | ~8 GB | Unsloth |
| `qwen2.5:14b` | 14B params | ~12–14 GB | Unsloth / Axolotl |
| `deepseek-v4-flash` | variable | verificar al momento | Unsloth |

> Si el modelo no cabe con QLoRA en 16 GB, entrenar `llama3:8b` como modelo principal y usar los demás en modo inferencia.

---

## Criterios de Aceptación

- [ ] El entorno de entrenamiento está instalado y funciona (Python, CUDA, Unsloth).
- [ ] Existe un dataset de entrenamiento con al menos **300 ejemplos** validados en formato JSONL.
- [ ] Al menos un modelo fine-tuneado pasa el **80% de pruebas manuales** sobre las 4 tareas del dominio.
- [ ] El modelo entrenado está exportado en formato GGUF y cargado en Ollama con nombre propio (ej. `dataflow-model`).
- [ ] El proceso completo es reproducible siguiendo el `README.md` del fine-tuning.
- [ ] Los datasets y configuraciones están versionados en `ai-services/fine-tuning/`.

---

## Fase 1 — Preparación del Entorno de Entrenamiento

### Requisitos de hardware
- GPU con al menos **8 GB de VRAM** (NVIDIA recomendado por soporte CUDA).
- RAM del sistema: mínimo 16 GB.
- Espacio en disco: ~50 GB libres (modelos base + checkpoints).

### Instalación de herramientas

```bash
# 1. Entorno Python
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Unsloth (fine-tuning eficiente para consumer hardware)
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
pip install --no-deps trl peft accelerate bitsandbytes

# 3. Dependencias adicionales
pip install datasets transformers sentencepiece protobuf
```

### Variables de entorno necesarias
```env
CUDA_VISIBLE_DEVICES=0
TOKENIZERS_PARALLELISM=false
HF_TOKEN=<token_de_huggingface_para_descargar_modelos>
```

---

## Fase 2 — Preparación del Dataset

### Formato de cada ejemplo (Alpaca format)

```json
{
  "instruction": "Limpia este dataset eliminando filas duplicadas y estandarizando el formato de fechas.",
  "input": "nombre,fecha,ciudad\nJuan Pérez,01/03/1990,bogotá\njuan pérez,1990-03-01,Bogotá",
  "output": "Se encontró 1 fila duplicada (Juan Pérez). Se eliminó la segunda entrada. Fechas estandarizadas a YYYY-MM-DD. Ciudades normalizadas a capitalización estándar.\n\nnombre,fecha,ciudad\nJuan Pérez,1990-03-01,Bogotá"
}
```

### Distribución mínima del dataset

| Tarea | Ejemplos mínimos | Descripción |
|-------|-----------------|-------------|
| Limpieza de datos | 80 | Duplicados, nulos, formatos incorrectos |
| Análisis de estructura | 70 | Descripción de columnas, tipos, anomalías |
| Normalización | 80 | Fechas, nombres, categorías, unidades |
| Resumen ejecutivo | 70 | Descripción en lenguaje natural del dataset |
| **Total** | **300** | |

### Reglas para los ejemplos
- Todo en español.
- Instrucciones variadas — no repetir el mismo enunciado.
- Los outputs deben estar verificados manualmente antes de incluirlos.
- No incluir datos personales reales (usar datos sintéticos o anonimizados).
- Incluir casos borde: datasets vacíos, columnas con todos nulos, fechas ambiguas.

### Script de conversión a JSONL

```python
# ai-services/fine-tuning/scripts/prepare_dataset.py
import json, random

def to_jsonl(examples: list[dict], output_path: str):
    random.shuffle(examples)
    n = len(examples)
    splits = {
        "train": examples[:int(n * 0.8)],
        "val":   examples[int(n * 0.8):int(n * 0.9)],
        "test":  examples[int(n * 0.9):]
    }
    for split, data in splits.items():
        with open(f"{output_path}/{split}.jsonl", "w", encoding="utf-8") as f:
            for row in data:
                f.write(json.dumps(row, ensure_ascii=False) + "\n")
```

---

## Fase 3 — Fine-Tuning con QLoRA (Unsloth)

### Script de entrenamiento base

```python
# ai-services/fine-tuning/train.py
from unsloth import FastLanguageModel
from trl import SFTTrainer
from transformers import TrainingArguments
from datasets import load_dataset

MAX_SEQ_LENGTH = 2048
MODEL_NAME = "unsloth/llama-3-8b-bnb-4bit"  # cambiar según modelo objetivo

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=MODEL_NAME,
    max_seq_length=MAX_SEQ_LENGTH,
    load_in_4bit=True,  # QLoRA — reducción de VRAM
)

model = FastLanguageModel.get_peft_model(
    model,
    r=16,               # LoRA rank
    lora_alpha=32,
    lora_dropout=0.05,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    bias="none",
    use_gradient_checkpointing="unsloth",
)

dataset = load_dataset("json", data_files={"train": "datasets/train.jsonl"})

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset["train"],
    dataset_text_field="text",
    max_seq_length=MAX_SEQ_LENGTH,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        num_train_epochs=3,
        learning_rate=2e-4,
        fp16=True,
        logging_steps=10,
        output_dir="checkpoints/",
        save_strategy="epoch",
        warmup_ratio=0.03,
        lr_scheduler_type="cosine",
    ),
)

trainer.train()
model.save_pretrained("model-trained/")
tokenizer.save_pretrained("model-trained/")
```

### Parámetros QLoRA recomendados por modelo

| Parámetro | Llama 3 8B | Qwen 2.5 14B | DeepSeek V4 Flash |
|-----------|-----------|--------------|-------------------|
| `load_in_4bit` | `True` | `True` | `True` |
| LoRA rank (`r`) | 16 | 8 | 16 |
| `lora_alpha` | 32 | 16 | 32 |
| Batch size | 2 | 1 | 2 |
| Grad. accumulation | 4 | 8 | 4 |
| Epochs | 3 | 3 | 3 |
| Learning rate | 2e-4 | 1e-4 | 2e-4 |

---

## Fase 4 — Exportar a GGUF y Cargar en Ollama

```python
# Exportar desde Unsloth
model.save_pretrained_gguf("model-gguf/", tokenizer, quantization_method="q4_k_m")
```

```bash
# Crear Modelfile para Ollama
cat > Modelfile <<EOF
FROM ./model-gguf/model-q4_k_m.gguf

SYSTEM """
Eres un asistente especializado en análisis y limpieza de datos tabulares en español.
Respondes de forma clara, estructurada y precisa. Cuando recibes un dataset, describes
sus problemas, propones correcciones y explicas cada paso realizado.
"""

PARAMETER temperature 0.3
PARAMETER top_p 0.9
PARAMETER num_ctx 4096
EOF

# Registrar en Ollama
ollama create dataflow-model -f ./Modelfile

# Probar
ollama run dataflow-model "Analiza este dataset: nombre,fecha\nJuan,01/03/90\njuan,1990-03-01"
```

---

## Fase 5 — Evaluación del Modelo

```bash
# ai-services/fine-tuning/evaluate.sh
#!/bin/bash
PASS=0; FAIL=0

while IFS= read -r line; do
  INSTRUCTION=$(echo "$line" | jq -r '.instruction')
  EXPECTED=$(echo "$line" | jq -r '.output')
  RESPONSE=$(ollama run dataflow-model "$INSTRUCTION" 2>/dev/null)

  if echo "$RESPONSE" | grep -qF "$EXPECTED"; then
    PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1))
    echo "FAIL: $INSTRUCTION"
  fi
done < datasets/test.jsonl

echo "Resultado: $PASS pasan / $((PASS+FAIL)) total"
```

> La evaluación automática es orientativa. Siempre complementar con **revisión manual** de al menos 30 casos del set de prueba.

---

## Estructura de Archivos

```
ai-services/fine-tuning/
├── datasets/
│   ├── raw/                          ← ejemplos sin validar
│   │   ├── limpieza.json
│   │   ├── analisis.json
│   │   ├── normalizacion.json
│   │   └── resumen.json
│   ├── validated/                    ← revisados manualmente
│   ├── train.jsonl
│   ├── val.jsonl
│   └── test.jsonl
├── scripts/
│   ├── prepare_dataset.py
│   └── evaluate.sh
├── checkpoints/                      ← guardados durante entrenamiento
├── model-trained/                    ← pesos LoRA entrenados
├── model-gguf/                       ← modelo exportado para Ollama
├── Modelfile                         ← configuración del modelo en Ollama
├── train.py                          ← script principal de entrenamiento
└── README.md
```

---

## Tareas

### Entorno
1. [ ] Verificar disponibilidad de GPU y VRAM (`nvidia-smi`).
2. [ ] Crear entorno Python e instalar Unsloth y dependencias.
3. [ ] Obtener token de Hugging Face y configurar en `.env`.
4. [ ] Probar descarga del modelo base (`llama3:8b`) en formato Hugging Face.

### Dataset
5. [ ] Definir y documentar el formato exacto de los ejemplos (Alpaca format).
6. [ ] Recolectar y anonimizar datasets reales del proyecto.
7. [ ] Crear 80 ejemplos de limpieza de datos.
8. [ ] Crear 70 ejemplos de análisis de estructura.
9. [ ] Crear 80 ejemplos de normalización.
10. [ ] Crear 70 ejemplos de resumen ejecutivo.
11. [ ] Validar manualmente todos los ejemplos.
12. [ ] Ejecutar `prepare_dataset.py` para generar `train/val/test.jsonl`.

### Entrenamiento
13. [ ] Ejecutar `train.py` con `llama3:8b` como modelo inicial.
14. [ ] Monitorear VRAM durante entrenamiento — no superar 16 GB.
15. [ ] Verificar que los checkpoints se guardan correctamente.
16. [ ] Evaluar el modelo con `evaluate.sh` y revisión manual.
17. [ ] Si el rendimiento es menor al 80%, ajustar parámetros y repetir.
18. [ ] Repetir el proceso con `qwen2.5:14b` y `deepseek-v4-flash` si el hardware lo permite.

### Publicación
19. [ ] Exportar el mejor modelo a GGUF con cuantización `q4_k_m`.
20. [ ] Crear `Modelfile` con el system prompt del dominio.
21. [ ] Registrar el modelo en Ollama como `dataflow-model`.
22. [ ] Verificar que `ollama run dataflow-model` responde correctamente.

### Documentación
23. [ ] Documentar parámetros usados, resultados y decisiones en `README.md`.
24. [ ] Registrar métricas de evaluación (% de acierto por tarea).

---

## Dependencias

- **HU-033** — Ollama y modelos base deben estar instalados.
- **HU-038** — Los datasets en preparación son la materia prima de esta HU.

---

## Notas

- Empezar siempre con `llama3:8b` — es el más liviano y el entrenamiento falla rápido si hay problemas.
- Si la GPU no soporta CUDA, se puede intentar entrenamiento en CPU con Unsloth, pero será muy lento (horas vs. minutos).
- Nunca commitear checkpoints ni pesos del modelo — solo el `Modelfile`, los scripts y los datasets validados.
- El dataset es el factor más importante: 300 ejemplos malos producen un modelo malo.

---

## Prioridad

**Media** — El sistema funciona con los modelos base mientras esta HU se completa. El fine-tuning mejora la calidad de respuestas pero no es bloqueante para el desarrollo de flujos.
