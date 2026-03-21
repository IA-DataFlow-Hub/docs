
## 1. Justificación del Stack Tecnológico Seleccionado

Para garantizar un ecosistema escalable y capaz de manejar flujos de datos complejos, se ha definido el siguiente stack:

- **Frontend: React + Vite:** Se elige React por su eficiencia en la gestión del estado y el DOM virtual. **Vite** se selecciona como herramienta de construcción por su soporte nativo para **Web Workers**, permitiendo trasladar procesos pesados de datos fuera del hilo principal de la interfaz.
    
- **Backend: Node.js (NestJS):** NestJS ofrece una arquitectura modular inspirada en Angular, lo que facilita el trabajo en equipo (Juan Diego y Oscar). Su motor basado en eventos es ideal para manejar múltiples conexiones concurrentes de entrada de datos.
    
- **Gestión de Entornos: Docker:** El uso de contenedores asegura que el procesamiento de archivos y el motor de IA corran en entornos aislados y controlados, evitando conflictos de dependencias y facilitando la escalabilidad horizontal.
    

---

## 2. Manejo de Archivos Pesados (Streams y Workers)

El procesamiento de grandes volúmenes de datos no estructurados requiere evitar el bloqueo de la aplicación. Se implementará una estrategia de **"Divide y Vencerás"**.

## Esquema Lógico de Procesamiento

1. **División en Bloques (Chunks):** El archivo se fragmenta en el cliente utilizando la API `Blob.slice()`.
    
2. **Transmisión por Streams:** Se utiliza el módulo `Stream` de Node.js en el backend para procesar los datos a medida que llegan, sin cargarlos por completo en la memoria RAM.
    
3. **Delegación a Workers:** Las tareas de limpieza profunda (OpenRefine) o análisis intensivo se envían a **Worker Threads** en el backend y **Web Workers** en el frontend.
    

## Librerías Sugeridas:

- **Backend:** `Multer` (para la gestión de streams de archivos) y `Worker_threads` (nativo de Node.js).
    
- **Frontend:** `PapaParse` (especializada en streams de archivos CSV pesados).
    

---

## 3. Protocolo de Comunicación: WebSockets

Para el feedback del chat y el monitoreo del procesamiento ETL en tiempo real, se implementará el protocolo **WebSockets** mediante la librería **Socket.io**.

- **Por qué:** A diferencia de HTTP tradicional, WebSockets permite una conexión bidireccional permanente.
    
- **Para qué:** * **Feedback de IA:** Permite recibir la respuesta de la IA palabra por palabra (streaming), mejorando la percepción de velocidad.
    
    - **Progreso de Tareas:** Informar al usuario el porcentaje exacto de la limpieza de datos o la carga del archivo pesado sin refrescar la página.
        

![WebSocket communication protocol diagram, generada por IA](https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcTVuPbBv472K4yeej1XjAXMx-cZoXY9_eVfPU7JDBNNiTVop-jWa6lh6fMXHLQvwqD_XmLPVa6XdTgEBs6OjyQekiEuKvTyioq1Ky5Gq_0r-vle2pE)

Shutterstock

Explorar

---

## 4. Integración Frontend con el Motor de IA

La facilidad de integración se califica como **Alta**, bajo la siguiente estrategia de orquestación:

- **Intermediación (API Gateway):** El Frontend no se comunica directamente con la IA (por seguridad y control de tokens). Juan Diego implementará un servicio en NestJS que actúe como puente.
    
- **Consumo de n8n:** El backend invocará flujos de **n8n** mediante webhooks. n8n procesará la lógica compleja y devolverá los datos estructurados al frontend.
    
- **Estandarización de Datos:** Se utilizará JSON como formato de intercambio para asegurar que los reportes de visualización (Power BI) y la interfaz de usuario lean la misma estructura de información.
    

---

## 5. Conclusión de la Investigación

El stack propuesto (React + NestJS + Docker) cumple con los criterios de la HU 03 al ofrecer:

1. **No bloqueo:** Gracias a Workers y Streams.
    
2. **Inmediatez:** Gracias a WebSockets para el chat.
    
3. **Escalabilidad:** Gracias a la arquitectura de contenedores liderada por Oscar y la integración de capas de Juan Diego.
    

**Estado de la HU:** Lista para inicio de desarrollo (Sprint Ready).

**NestJS** es uno de los frameworks más robustos para integrar este tipo de ecosistemas complejos debido a su arquitectura modular y su excelente soporte para TypeScript. Al ser el "cerebro" de **IA-DataFlow Hub**, NestJS permite orquestar todas estas piezas de la siguiente manera:

## 1. Integración con n8n (Orquestación de Flujos)

NestJS no reemplaza a n8n, sino que lo consume. Puedes configurar NestJS para:

- **Disparar Webhooks:** Enviar datos desde tu aplicación a n8n para que este ejecute procesos de limpieza en OpenRefine o guarde datos en bases de datos críticas.
    
- **Recibir Webhooks:** n8n puede notificar a NestJS cuando un flujo de datos ha terminado, permitiendo que el backend actualice la interfaz de usuario en tiempo real.
    

## 2. Manejo de Modelos (Llama 4 y Gemini)

NestJS permite una integración limpia mediante servicios dedicados:

- **Llama 4:** Si lo corres localmente (usando Ollama o LocalAI), NestJS se comunica mediante una API REST local. Es ideal para procesos donde la privacidad de los datos es crítica.
    
- **Gemini:** Utilizando el SDK oficial de Google Generative AI (`@google/generative-ai`), puedes integrar Gemini Pro directamente en tus servicios de NestJS para análisis semántico avanzado.
    

## 3. Agentes, Skills e Instrucciones (El Núcleo de la IA)

Para que el **IA-DataFlow Hub** sea realmente un "Centro de Comando", NestJS gestiona la lógica de los agentes:

- **Instrucciones (System Prompts):** Puedes crear decoradores o servicios en NestJS que inyecten las "reglas de negocio" o el estándar **TOON** a cada petición que se envía al modelo. Esto asegura que la IA siempre responda bajo los parámetros del proyecto.
    
- **Skills (Funciones/Herramientas):** Mediante el concepto de _Function Calling_, puedes definir "habilidades" en NestJS. Por ejemplo, si el usuario pide "Analiza este Excel", la IA detecta que necesita la "Skill de Lectura" y NestJS ejecuta la lógica de código necesaria para procesar ese archivo.
    
- **Agentes Autónomos:** Usando librerías como **LangChain.js** dentro de NestJS, puedes crear agentes que razonen y decidan qué pasos seguir (ej. 1. Limpiar datos -> 2. Consultar IA -> 3. Generar JSON para Power BI).
    

## Beneficios Técnicos para el Equipo

1. **Inyección de Dependencias:** se  puede crear un `AIService` y Oscar puede consumirlo en cualquier parte del sistema de forma desacoplada.
    
2. **Seguridad:** NestJS actúa como un guardián (Proxy), asegurando que las llaves de API de Gemini no estén expuestas en el frontend.
    
3. **Escalabilidad con Docker:** Al estar todo en NestJS, se puede "dockerizar" el backend y asegurar que los agentes tengan siempre las mismas librerías y versiones de Python (si se requiere) disponibles.
    

**En resumen:** NestJS es el pegamento perfecto. Permite que la IA no sea solo un chat, sino un sistema funcional que ejecuta tareas, sigue instrucciones precisas y utiliza herramientas externas para transformar datos no estructurados en conocimiento real.