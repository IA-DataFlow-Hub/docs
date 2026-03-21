
El proyecto implementa una infraestructura robusta diseñada para transformar datos no estructurados en conocimiento real, utilizando un modelo de **API Gateway** que orquesta la inteligencia artificial, el procesamiento de archivos pesados y la comunicación en tiempo real.

## 1. El Stack Tecnológico (Ecosistema de Control)

Se ha seleccionado un conjunto de herramientas que garantiza escalabilidad horizontal y aislamiento de procesos:

- **Frontend (React + Vite):** Utiliza _Web Workers_ para procesar datos en el navegador sin congelar la interfaz de usuario.
    
- **Backend (NestJS):** Actúa como el "cerebro" y guardián del sistema. Orquesta la lógica de negocio, gestiona la seguridad (API Keys) y conecta las IAs.
    
- **Infraestructura (Docker):** Garantiza que el motor de IA y el backend corran en entornos aislados, evitando conflictos de dependencias.
    

---

## 2. Gestión de Datos Masivos (Estrategia "Divide y Vencerás")

Para procesar 100k+ registros sin colapsar la memoria RAM (**Heap Out of Memory**), se aplican tres técnicas clave:

1. **Streams:** Lectura progresiva de archivos. El sistema procesa los datos conforme llegan, en lugar de cargarlos todos a la vez.
    
2. **Worker Threads:** Delegación de tareas pesadas (limpieza con OpenRefine o cálculos) a hilos secundarios, manteniendo el servidor principal siempre disponible.
    
3. **Chunking:** Fragmentación de archivos desde el cliente para una transmisión eficiente y controlada.
    

---

## 3. Comunicación y Feedback en Tiempo Real

Para eliminar las esperas y las consultas repetitivas (_polling_), se implementa **Socket.IO (WebSockets)**:

- **Interacción Bidireccional:** El servidor "empuja" las respuestas de la IA palabra por palabra (_streaming_).
    
- **Monitoreo ETL:** El usuario visualiza el porcentaje exacto de progreso de limpieza y carga de datos de forma inmediata.
    

---

## 4. Orquestación de Inteligencia Artificial

NestJS integra las capacidades de IA no como un simple chat, sino como un sistema funcional:

- **Híbrido Nube/Local:** Conexión con **Llama 4** (vía Ollama) para privacidad total y con **Gemini** (vía SDK oficial) para análisis semántico avanzado con acceso a internet.
    
- **Consumo de n8n:** El backend dispara flujos de trabajo en n8n mediante webhooks para limpiezas complejas y estructuración de datos.
    
- **Jerarquía de Agentes:** NestJS gestiona los _System Prompts_ (instrucciones) y las _Skills_ (habilidades técnicas) para que la IA pueda ejecutar acciones como generar archivos para Power BI o consultar bases de datos SQL.
    

---

## 5. Seguridad y Cumplimiento Legal

- **Protección de Datos:** Todo el tratamiento de información se alinea con la **Ley 1581 de 2012** (Colombia), asegurando la privacidad del usuario.
    
- **Autenticación:** Implementación de guardias de seguridad en el _handshake_ de WebSockets y protección de credenciales mediante el backend (Proxy).
    

---

## 💡 Conclusión Integrada de los Investigadores

La sinergia entre **React + NestJS + n8n + Docker** consolida a **IA-Dataflow** como un ecosistema modular de alto rendimiento. En esta arquitectura, cada capa cumple un rol crítico para el éxito del proyecto:

- **Interfaz Inteligente (React + Vite):** El frontend no es solo visual; gracias a los _Web Workers_, **React** asume la carga de pre-procesar y fragmentar archivos pesados en el navegador, garantizando una interfaz fluida que nunca se bloquea, incluso con 100k registros. ⚛️
    
- **Cerebro y Orquestación (NestJS + n8n):** NestJS actúa como el guardián de la lógica y la seguridad, mientras que n8n automatiza los flujos de limpieza profunda. Juntos, permiten que la IA ejecute tareas complejas de forma asíncrona. 🧠
    
- **Escalabilidad y Potencia (Docker + Motores IA):** El uso de contenedores permite que el motor de IA (Llama 4/Gemini) escale de forma independiente —por ejemplo, en servidores con GPU— sin afectar la estabilidad del sistema ni la experiencia del usuario final. 🐳
    

## ✅ Veredicto Técnico

El sistema está **técnicamente validado** para manejar flujos ETL complejos con **inmediatez** (vía WebSockets en React) y **seguridad** (bajo la Ley 1581). La arquitectura es **Sprint Ready**, permitiendo un desarrollo desacoplado donde el equipo puede trabajar en el motor de IA, el backend o la interfaz de forma simultánea y eficiente.