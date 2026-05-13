# HU-033 — Configuración del Entorno de IA (Ollama + LM Studio + Gemini)

## Historia de Usuario

**Como** equipo de desarrollo,  
**Quiero** tener el entorno de IA local y cloud configurado y funcionando,  
**Para** poder probar y desarrollar las funciones de procesamiento inteligente sin esperar a que los datasets de fine-tuning estén listos.

---

## Contexto

El sistema usa un modelo híbrido de IA:

**Local (sin salir de la red)** — para datos sensibles:
- **DeepSeek V4 Flash** vía Ollama — modelo principal para razonamiento y análisis.
- **Llama 3** vía Ollama — alternativa general, ligera y probada.
- **Qwen 2.5 14B** vía Ollama — respaldo para tareas en español y datos estructurados.
- **LM Studio** — interfaz gráfica local con API compatible con OpenAI (`http://localhost:1234/v1`), útil para probar modelos GGUF sin Docker.

**Cloud** — para procesamiento masivo:
- **Gemini 2.5 Flash-Lite** — rápido y económico para grandes volúmenes.

> Los modelos locales no corren simultáneamente — cada uno se carga según la tarea. Todos deben respetar el límite de **16 GB de RAM/VRAM**.

Esta HU cubre montar el entorno, verificar que todos los motores responden y dejar los prompts base listos. El fine-tuning vendrá después, cuando los datasets estén preparados.

---

## Criterios de Aceptación

- [ ] Ollama instalado y corriendo con los modelos `deepseek-v4-flash`, `llama3` y `qwen2.5:14b-instruct-q4_K_M` descargados.
- [ ] Cada modelo local **no supera 16 GB de RAM/VRAM** al cargarse (verificado con `ollama ps`).
- [ ] LM Studio instalado y levantando su servidor local en `http://localhost:1234/v1`.
- [ ] Se puede enviar un prompt a Ollama y a LM Studio desde la terminal y desde n8n.
- [ ] La API key de Gemini está configurada en el `.env` y funciona con una llamada de prueba.
- [ ] Existe un archivo de prompts base en `ai-services/prompts/` para las tareas principales.
- [ ] Los motores locales y cloud están documentados en `docker-compose.yml` con sus URLs.
- [ ] Hay documentación de cómo cambiar entre los motores local y cloud.

---

## Tareas

### Ollama (Local)
1. [ ] Instalar Ollama en el servidor/máquina de desarrollo.
2. [ ] Descargar modelos (verificar que cada uno no supere 16 GB al cargar):
   - `ollama pull deepseek-v4-flash`
   - `ollama pull llama3`
   - `ollama pull qwen2.5:14b-instruct-q4_K_M` (~9 GB)
3. [ ] Verificar consumo de memoria con `ollama ps` por cada modelo — confirmar límite de **16 GB**.
4. [ ] Verificar respuesta de cada modelo: `curl http://localhost:11434/api/generate` con prompt de prueba.
5. [ ] Agregar al `.env`:
   ```
   OLLAMA_URL=http://ollama:11434
   OLLAMA_MODEL_DEFAULT=deepseek-v4-flash
   ```
6. [ ] Agregar servicio `ollama` al `docker-compose.yml` si se corre en contenedor.

### LM Studio (Local — interfaz gráfica)
7. [ ] Instalar LM Studio en la máquina de desarrollo.
8. [ ] Cargar un modelo GGUF compatible (ej. DeepSeek o Llama3 en formato GGUF).
9. [ ] Activar el servidor local en LM Studio (`http://localhost:1234/v1`).
10. [ ] Verificar que la API responde: `curl http://localhost:1234/v1/models`.
11. [ ] Agregar `LM_STUDIO_URL=http://localhost:1234/v1` al `.env`.

### Gemini (Cloud)
12. [ ] Obtener API key de Google AI Studio.
13. [ ] Agregar `GEMINI_API_KEY` y `GEMINI_MODEL=gemini-2.5-flash-lite` al `.env`.
14. [ ] Crear script de prueba en `ai-services/` que llame a Gemini y muestre la respuesta.

### Prompts Base
15. [ ] Crear prompt para **limpieza de datos**: detectar y corregir nulos, duplicados y formatos.
16. [ ] Crear prompt para **análisis de estructura**: describir columnas, tipos y anomalías de un CSV.
17. [ ] Crear prompt para **normalización**: estandarizar fechas, nombres y categorías.
18. [ ] Crear prompt para **resumen ejecutivo**: generar descripción en lenguaje natural de un dataset.

### Documentación
19. [ ] Documentar en `ai-services/README.md` cómo cambiar entre motores (DeepSeek, Llama3, Qwen, LM Studio, Gemini).
20. [ ] Documentar el formato esperado de entrada y salida de cada prompt.

---

## Estructura de Archivos

```
ai-services/
├── prompts/
│   ├── limpieza-datos.txt
│   ├── analisis-estructura.txt
│   ├── normalizacion.txt
│   └── resumen-ejecutivo.txt
├── scripts/
│   ├── test-ollama.sh
│   ├── test-lmstudio.sh
│   └── test-gemini.js
└── README.md
```

---

## Notas

- El fine-tuning NO es parte de esta HU — depende de que los datasets estén listos (tarea paralela).
- Los prompts deben funcionar con todos los motores (DeepSeek, Llama3, Qwen, LM Studio y Gemini).
- Nunca commitear API keys reales — solo usar `.env` ignorado por git.
- **Restricción de memoria:** el modelo local nunca debe superar **16 GB de RAM/VRAM**. Si un modelo base no cabe, se debe usar cuantización (`q4_K_M` o inferior). Modelos no cuantizados que excedan este límite quedan descartados.

## Prioridad

**Alta** — bloquea el desarrollo de todos los flujos de IA en n8n y el backend.
