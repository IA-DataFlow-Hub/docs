## HU 01: Infraestructura y Viabilidad de Servidores

**Como** equipo de infraestructura, **quiero** consultar valores de servidores, su soporte para Node.js y escalabilidad, **para** asegurar que el entorno de despliegue soporte la carga de procesos pesados y WebSockets.

- **Criterios de Aceptación**: Cuadro comparativo de al menos 3 proveedores (AWS, DigitalOcean, Hostinger) y validación de soporte para procesos en segundo plano.
    
- **Tareas**:
    
    - [ ] Cotizar VPS con capacidad de escalado en RAM y CPU.
        
    - [ ] Investigar la facilidad de despliegue para aplicaciones Node.js/Python.
        
    - [ ] Consultar latencia de servidores para asegurar respuesta rápida del Chatbot.
        
    - [ ] Investigar si el servidor soporta conexiones persistentes (WebSockets).
        
- **👥 Equipo**: **Sebastián Bautista Martínez** y **Andres Felipe Andrade**.
    
- **💡 Nota de elección**: Sebastián aporta su experiencia en Nube (AWS/Azure) y alta disponibilidad, mientras que Andrés Felipe garantiza la solidez en la administración de servidores Windows/Linux.
    

---

## HU 02: Análisis de IA, Herramientas ETL y Economía de Tokens

**Como** equipo de inteligencia artificial, **quiero** investigar modelos de IA, librerías de procesamiento y herramientas ETL junto con sus costos de operación, **para** seleccionar la opción más rentable para procesar y limpiar grandes volúmenes de datos.

- **Criterios de Aceptación**: Tabla de costos de modelos (GPT-4o, Claude 3.5, Gemini) e investigación de herramientas de orquestación como n8n o LangChain.
    
- **Tareas**:
    
    - [ ] Realizar pruebas de limpieza de datos con modelos de bajo costo vs. premium.
        
    - [ ] Proyectar el gasto para volúmenes de 20k, 50k y 100k registros.
        
    - [ ] Investigar herramientas de orquestación (n8n, LangChain o LlamaIndex).
        
    - [ ] Investigar "Rate Limits" de las APIs para evitar bloqueos del sistema.
        
- **👥 Equipo**: **Juan Diego Mejía** y **Brayan Monterrosa**.
    
- **💡 Nota de elección**: Juan Diego lidera la visión de metodologías ágiles y arquitectura, y Brayan Monterrosa evalúa técnicamente las librerías de IA gracias a su foco en Python y JavaScript.
    

---

## HU 03: Stack Tecnológico y Manejo de Procesos

**Como** equipo de arquitectura, **quiero** investigar los mejores lenguajes y frameworks para Frontend y Backend, **para** elegir la tecnología que mejor gestione el procesamiento por hilos y la comunicación en tiempo real.

- **Criterios de Aceptación**: Justificación técnica del stack y esquema lógico de división de archivos pesados en hilos o bloques.
    
- **Tareas**:
    
    - [ ] Investigar librerías para manejo de archivos pesados (Streams o Workers).
        
    - [ ] Definir el protocolo de comunicación (WebSockets) para el feedback del chat.
        
    - [ ] Evaluar la facilidad de integración del Frontend con el motor de IA.
        
- **👥 Equipo**: **Juan Diego Mejía** y **Oscar Antury Avila**.
    
- **💡 Nota de elección**: Juan Diego asegura la conexión entre capas y Oscar aporta su dominio de React y contenedores (Docker) para un stack escalable.
    

---

## HU 04: Optimización de UX y Evolución de Dashboards

**Como** equipo de producto, **quiero** analizar el prototipo actual e investigar tendencias colaborativas, **para** proponer mejoras que optimicen la experiencia del usuario y la efectividad de los 4 tableros.

- **Criterios de Aceptación**: Informe de auditoría del prototipo actual (https://ia-dataflow.codigolimpio.com.co/) y definición de KPIs para los 4 tableros.
    
- **Tareas**:
    
    - [ ] Investigar bibliotecas de gráficos (Recharts/D3.js) para los tableros.
        
    - [ ] Diseñar el flujo de "Gestión de Colaboradores" (invitaciones y roles).
        
    - [ ] Investigar el manejo de estados compartidos en tiempo real.
        
    - [ ] Realizar auditoría del prototipo actual identificando "puntos de dolor".
        
- **👥 Equipo**: Oscar Antury Avila y **María Virginia Labarca**.
    
- **💡 Nota de elección**: David aporta su visión técnica en Angular para mejorar el Front, y María utiliza su experiencia en soporte nivel II para priorizar la facilidad de uso para el cliente.
    

---

## HU 05: Seguridad, Privacidad y Cumplimiento (Ley 1581)

**Como** equipo de seguridad, **quiero** investigar normativas legales (SIC), estándares de cifrado y protocolos de consentimiento, **para** garantizar que el manejo de datos cumpla con la ley colombiana.

- **Criterios de Aceptación**: Definición de cumplimiento con la Ley 1581 de 2012 y protocolos técnicos como SSL/TLS y AES-256.
    
- **Tareas**:
    
    - [ ] Investigar requisitos de la SIC para el tratamiento de datos personales (Ley 1581).
        
    - [ ] Revisar si los datos de las APIs se usan para entrenar modelos externos.
        
    - [ ] Diseñar el mecanismo de consentimiento informado (Aviso de Privacidad).
        
    - [ ] Investigar implementación de SSL/TLS y seguridad en el servidor VPS.
        
    - [ ] Definir política de borrado automático de archivos temporales.
        
- **👥 Equipo**: **Pohlman Cuartas** y **David Ospina**.
    
- **💡 Nota de elección**: Pohlman aporta rigor de sistemas críticos (ATM) para la seguridad, y David conecta los requisitos legales con la arquitectura técnica.
    

---

## HU 06: Arquitectura de Software y Modelado UML

**Como** equipo de análisis, **quiero** traducir requerimientos en diagramas de arquitectura, secuencia y modelo entidad-relación, **para** definir la estructura técnica y el flujo de comunicación con la IA.

- **Criterios de Aceptación**: Diagrama de Arquitectura de N-Capas, Diagrama Entidad-Relación (DER) y estándar JSON para intercambio de datos.
    
- **Tareas**:
    
    - [ ] Diseñar el esquema de tablas que soporte proyectos, versiones y usuarios.
        
    - [ ] Definir los metadatos mínimos que la IA debe extraer de cada carga.
        
    - [ ] Revisar el documento técnico del profesor para extraer reglas de negocio.
        
    - [ ] Crear diagrama de secuencia del flujo de limpieza de datos.
        
- **👥 Equipo**: **Juan Diego Mejía** y **Andrés Felipe Andrade**.
    
- **💡 Nota de elección**: Juan Diego asegura que el modelado responda al negocio, y Andrés aporta su foco en lógica de backend para que el modelo sea ejecutable en servidores reales.