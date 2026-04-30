


# ⚙️ HU 03: Stack Tecnológico y Manejo de Procesos

**Proyecto:** IA Dataflow

**Tags:** #Arquitectura #NodeJS #NestJS #IA #WebSockets

---

## 1. Gestión de Archivos Pesados

Para evitar errores de memoria (**Heap Out of Memory**) al procesar datasets masivos, se implementa una estrategia de lectura y ejecución desacoplada:

- **Streams:** Lectura progresiva que evita cargar archivos completos en RAM.
    
- **Worker Threads:** Procesamiento paralelo de transformaciones sin bloquear el Event Loop.
    
- **Chunking:** División de grandes datasets (ej. 100k registros) en lotes manejables.
    

> [!INFO] Fuentes Técnicas
> 
> - [Node.js Streams](https://nodejs.org/api/stream.html)
>     
> - [Node.js Worker Threads](https://nodejs.org/api/worker_threads.html)
>     

---

## 2. Comunicación en Tiempo Real

Se implementa **Socket.IO (WebSockets)** para lograr una interacción bidireccional de baja latencia entre el cliente y el servidor.

- **Ventajas:** Proporciona fallback automático a HTTP Long-Polling y reconexión gestionada.
    
- **Eficiencia:** El backend empuja el progreso de tareas y respuestas de la IA de forma asíncrona, eliminando la necesidad de polling (consultas repetitivas) desde el frontend.
    
- _Fuente:_ [Socket.IO](https://socket.io/)
    

---

## 3. Integración de Sistemas (Frontend – Backend – IA)

La arquitectura utiliza un patrón de **API Gateway mediante NestJS** para asegurar la escalabilidad y el desacoplamiento de capas.

## Flujo de Datos

1. **Frontend (React):** Envía solicitudes vía WebSockets o REST.
    
2. **Backend (NestJS):** Orquesta la lógica de negocio, gestiona autenticación y delega tareas a los Workers.
    
3. **Motor IA (Python):** Ejecuta inferencias y retorna resultados al backend.
    
4. **Respuesta:** El backend entrega los datos procesados a la UI de forma inmediata.
    

**Ventaja:** El motor de IA puede escalarse de forma independiente (ej. en servidores con GPU) sin comprometer el rendimiento global del sistema.

---

## 🛡️ Seguridad y Cumplimiento

- **Autenticación:** NestJS permite integrar protecciones robustas en el handshake de las conexiones WebSocket.
    
- **Normativa:** Todo tratamiento de datos debe regirse por la **Ley 1581 de 2012** sobre Protección de Datos Personales en Colombia.
    
    - _Fuente:_ [Ley 1581 de 2012](https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=49981)