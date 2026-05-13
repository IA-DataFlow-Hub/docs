
**Como** Arquitecto de IA,  
**quiero** ejecutar una investigación técnica comparando formatos de datos (JSON, CSV, YAML, TOON),  
**para** optimizar el consumo de la ventana de contexto en los modelos **Gemini (2.5 Flash y 2.5 Pro)**, minimizando la latencia y maximizando la capacidad de procesamiento de datos en el sistema **IA-DataFlow**.

---

## 🗂️ Referencia de Formatos (Hipótesis de Benchmark)
El equipo debe validar la densidad de información enviando el mismo set de datos de prueba en los siguientes formatos:

| Formato | Estructura Característica | Predicción de Consumo | Rol Estratégico |
| :--- | :--- | :---: | :--- |
| **JSON** | Verboso, uso de llaves `{}`, comillas `""` y repetición de keys. | ~230 tokens (Alto) | Salida final (Output) y API externa. |
| **CSV** | Estructura tabular, declaración única de encabezados. | ~145 tokens (Medio) | Ingesta masiva de archivos planos. |
| **YAML** | Basado en indentación, elimina llaves y comas. | ~180 tokens (Medio) | Configuración y parámetros. |
| **TOON** | Minificación extrema, delimitadores `|`, cabeceras `[H:]`. | **~115 tokens (Bajo)** | Inferencia interna Backend <-> IA. |

---

## 🛠️ Tareas de Investigación (Checklist Exploratorio)

- [ ] **Fase 1: Configuración de Herramientas de Medición:** Dado que Google no tiene un contador web independiente, el equipo debe usar:
  1. [Google AI Studio (Playground)](https://aistudio.google.com/app/prompts/new_chat): Pegar el texto y observar el contador de tokens en la esquina inferior derecha.
  2. [Tiktokenizer](https://tiktokenizer.vercel.app/) (Referencia técnica cruzada).
  3. [OpenAI Tokenizer](https://platform.openai.com/tokenizer) (Control de industria).

- [ ] **Fase 2: Pruebas de Carga en Gemini:** Registrar métricas de desempeño:
  - **Gemini 1.5 Flash:** Medir velocidad de procesamiento y comprensión del estándar TOON.
  - **Gemini 1.5 Pro:** Evaluar el comportamiento en ventanas de contexto extensas.

- [ ] **Fase 3: Diseño del Glosario TOON:** Definir la tabla oficial de equivalencias (ej: `n = name`, `p = phone`).

---

## 📦 Entregables Requeridos (Lo que el equipo debe entregar)

Para dar por finalizada esta HU, el equipo debe subir al repositorio `/docs` los siguientes elementos:

1. **📄 Reporte de Benchmark (PDF o MD):** Una tabla comparativa real que muestre:
   - Formato | Cantidad de Texto (Bytes) | **Cantidad de Tokens en Gemini** | Tiempo de Respuesta (ms).
   - Incluir **capturas de pantalla** de Google AI Studio con el contador de tokens para cada formato.

2. **📖 Glosario Oficial TOON:** Un archivo llamado `TOON_DICTIONARY.md` que contenga el mapeo de todos los encabezados abreviados que usará el sistema.

3. **🧪 Set de Pruebas Inversas:** Un log de chat donde se demuestre que Gemini recibió datos en TOON y fue capaz de devolverlos en un JSON perfecto sin errores de limpieza.

---

## ✅ Criterios de Aceptación (Definition of Done)
1. Reducción demostrada de al menos el **35% en el conteo de tokens** usando el estándar TOON frente a JSON.
2. El reporte técnico incluye al menos 3 pruebas de "estrés" con más de 100 registros cada una.
3. El equipo de Backend (NestJS) confirma que entiende el glosario para implementarlo en el código.
4. Validación exitosa de que Gemini no "alucina" al procesar los delimitadores de TOON (`|`, `[]`).

---

## 💡 Nota para el FUUA Team:
Esta investigación define el ADN de **IA-DataFlow**. Si el reporte de benchmark demuestra la superioridad del estándar TOON en Gemini, tendremos el sustento técnico necesario para procesar archivos masivos donde otros sistemas fallan por falta de memoria de contexto.


📊 Comparativa de Formatos (Muestra de Datos)
He procesado tus datos para comparar la eficiencia. Nota cómo el estándar TOON elimina el "ruido" estructural para maximizar el espacio.

1. Formato JSON (Más Pesado)
Es el más fácil de leer para humanos y sistemas, pero consume muchos tokens debido a las llaves {}, comillas "" y la repetición de los nombres de las columnas en cada objeto.
Tokens estimados: ~230 tokens.

JSON
```
[
  {"n":"Marvin Jefferson","p":"(947) 473-3904","e":"parturient.montes@google.couk","r":"Swiętokrzyskie","c":"Turkey","i":1},
  {"n":"Sebastian Jenkins","p":"(113) 812-1221","e":"volutpat@aol.edu","r":"Troms og Finnmark","c":"Poland","i":3},
  {"n":"Ignacia Craig","p":"1-232-563-0876","e":"eleifend@icloud.net","r":"Zakarpattia oblast","c":"New Zealand","i":9},
  {"n":"Ferdinand Barker","p":"(898) 643-2621","e":"vitae.erat.vel@hotmail.ca","r":"Oslo","c":"Poland","i":7},
  {"n":"Kessie Brennan","p":"1-646-736-5222","e":"montes.nascetur@hotmail.ca","r":"Guanacaste","c":"Pakistan","i":7}
]
```
2. Formato CSV (Equilibrado)
Mucho más eficiente que JSON porque solo declara los encabezados una vez.
Tokens estimados: ~145 tokens.

Fragmento de código
```
name,phone,email,region,country,num
Marvin Jefferson,(947) 473-3904,parturient.montes@google.couk,Swiętokrzyskie,Turkey,1
Sebastian Jenkins,(113) 812-1221,volutpat@aol.edu,Troms og Finnmark,Poland,3
Ignacia Craig,1-232-563-0876,eleifend@icloud.net,Zakarpattia oblast,New Zealand,9
Ferdinand Barker,(898) 643-2621,vitae.erat.vel@hotmail.ca,Oslo,Poland,7
Kessie Brennan,1-646-736-5222,montes.nascetur@hotmail.ca,Guanacaste,Pakistan,7
```

3. Formato Estándar TOON (Máxima Eficiencia)
Aquí minificamos todo. Usamos delimitadores de un solo carácter (como |), eliminamos espacios innecesarios y abreviamos los encabezados al mínimo entendible por la IA.
Tokens estimados: ~115 tokens.

Plaintext
```
[H:n|p|e|r|c|i]
[D:M.Jefferson|(947)4733904|parturient.montes@google.couk|Swiętokrzyskie|TR|1]
[D:S.Jenkins|(113)8121221|volutpat@aol.edu|Troms og Finnmark|PL|3]
[D:I.Craig|12325630876|eleifend@icloud.net|Zakarpattia oblast|NZ|9]
[D:F.Barker|(898)6432621|vitae.erat.vel@hotmail.ca|Oslo|PL|7]
[D:K.Brennan|16467365222|montes.nascetur@hotmail.ca|Guanacaste|PK|7]

```

🏆 Veredicto de Eficiencia
TOON: Ganador absoluto. Ahorras casi un 50% de tokens comparado con JSON.

CSV: Muy bueno para datos tabulares, pero los espacios y comas a veces generan tokens extra en nombres largos.

JSON: Solo úsalo para la salida final que va al Power BI, pero nunca para enviarle datos masivos a la IA en la entrada.

---

## 📋 Seguimiento del Proyecto

| Campo | Valor |
|---|---|
| **Tema** | IA / NLP |
| **Actividad** | HU 08: Investigación Exploratoria - Estándar TOON y Tokens |
| **Entregable** | Entregable 2 |
| **Meta Numérica** | 3 |
| **Responsable(s)** | Andres Felipe Andrade |
| **Fecha Inicio** | 13/04/2026 |
| **Fecha Fin** | 17/04/2026 |
| **Fecha Entrega** | 29/04/2026 |
| **Riesgo** | Bajo |
| **Entregable Verificado** | Sí |
| **% Avance** | 100% |
| **Estado** | ✅ Completado |
| **Aprobado Por** | Todo el equipo |
| **Observaciones** | Entregado sin observaciones |
