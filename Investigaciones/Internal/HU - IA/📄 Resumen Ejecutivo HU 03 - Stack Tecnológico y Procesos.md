**Fecha:** 10 de marzo de 2026
**Responsables:** Juan Diego Mejía / Oscar Antury Avila
**Estado:** Definición de Arquitectura Técnica

## 1. Stack Tecnológico Propuesto

Tras analizar la necesidad de manejar **WebSockets** e **IA**, se preseleccionan las siguientes tecnologías por su eficiencia en I/O (Entrada/Salida).

|**Capa**|**Tecnología**|**Justificación Técnica**|**Enlace Oficial**|
|---|---|---|---|
|**Frontend**|**React.js**|Alta reactividad y manejo eficiente del estado global para dashboards.|[Ver React](https://react.dev/)|
|**Backend**|**Node.js (Fastify)**|Más veloz que Express; ideal para manejar miles de conexiones simultáneas.|[Ver Fastify](https://fastify.dev/)|
|**Comunicación**|**Socket.io**|Protocolo de WebSockets con reconexión automática para el Chatbot.|[Ver Socket.io](https://socket.io/)|

---

## 2. Manejo de Procesos Pesados (Multithreading)

Para evitar que el procesamiento de **100k registros** bloquee el servidor (Event Loop), se implementarán las siguientes estrategias:

- **Worker Threads (Node.js):** Permite ejecutar la lógica de limpieza de la IA en hilos separados de la CPU, manteniendo la API disponible para otros usuarios. [Doc Worker Threads](https://nodejs.org/api/worker_threads.html)
    
- **Web Workers (Frontend):** Si el navegador debe procesar parte del CSV, se usará un hilo secundario para no "congelar" la pestaña del usuario. [Doc Web Workers](https://developer.mozilla.org/es/docs/Web/API/Web_Workers_API)
    
- **Streams:** Lectura de archivos "trozo a trozo" (chunks) en lugar de cargar todo el archivo en la memoria RAM del servidor.
    

---

## 3. Esquema Lógico de Procesamiento

1. **Carga:** El usuario sube un archivo pesado (>10MB).
    
2. **Streaming:** El Backend lo recibe por fragmentos y lo guarda temporalmente.
    
3. **Hilos:** Un _Worker Thread_ toma el archivo y empieza a enviarlo por lotes (batches) al motor de IA (HU 02).
    
4. **Feedback:** Cada 10% de avance, el servidor envía un mensaje por **WebSocket** al Frontend para actualizar la barra de progreso en tiempo real.
    

---

## 4. Integración con el Motor de IA

- **API Rest / SDK:** Se usará el SDK oficial de **Google AI** para Node.js, que ofrece la menor latencia de integración para Gemini 1.5 Flash. [SDK Google AI](https://www.npmjs.com/package/@google/generative-ai)
    
- **Contenedores:** El stack se empaquetará en **Docker** (Expertiz de Oscar) para asegurar que funcione igual en el VPS (HU 01) que en nuestras máquinas locales. [Ver Docker](https://www.docker.com/)
    

---

## 5. Conclusión / Recomendación

Se recomienda el uso de **Node.js con Fastify** y **Worker Threads** para el Backend, y **React** para el Frontend. Esta combinación permite una comunicación fluida por WebSockets y garantiza que el servidor pueda limpiar datos de múltiples empresas simultáneamente sin degradar el rendimiento.