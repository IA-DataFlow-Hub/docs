---

kanban-plugin: board

---

## Definicion

- [ ] ## HU 01: Investigación de Infraestructura y Costos
	
	**Como** integrante del equipo unificado, **Quiero** investigar los costos de hosting, dominio y tokens de IA, **Para** presentar un presupuesto viable al profesor Raúl el próximo sábado.
	
	**Criterios de Aceptación:**
	
	- Presentar una tabla comparativa de al menos 3 proveedores de VPS/Hosting.
	    
	- Incluir el costo de un dominio (.com o .co) por un año.
	    
	- Entregar el análisis de costos de tokens para procesar 1k, 20k, 50k y 100k registros.
	    
	
	**Tareas:**
	
	- [ ] Cotizar VPS con soporte para Node.js/React en Hostinger, AWS y DigitalOcean.
	    
	- [ ] Buscar disponibilidad y precio del nombre de dominio para el proyecto.
	    
	- [ ] Calcular consumo de tokens según el modelo de IA seleccionado (ej. GPT-4o o Claude).
	    
	- [ ] Redactar informe de presupuesto en formato PDF/Markdown.
- [ ] ## HU 02: Investigación y Definición de la Arquitectura Técnica
	
	**Como** desarrollador del proyecto IA-DataFlow, **Quiero** investigar y comparar diferentes lenguajes y frameworks para Frontend y Backend, **Para** seleccionar la arquitectura que mejor soporte el procesamiento de datos por hilos y la comunicación mediante WebSockets.
	
	**Criterios de Aceptación:**
	
	- Entregar un cuadro comparativo de al menos dos stacks tecnológicos (ej. React vs. Angular para Front; Node.js vs. Python para Back).
	    
	- Justificar cuál lenguaje maneja mejor el **multithreading** o procesamiento por bloques para archivos de más de 10,000 registros.
	    
	- Validar qué tecnología facilita la implementación de **WebSockets** para que el usuario vea el avance de la limpieza de datos en tiempo real.
	    
	- Definir la herramienta de base de datos o almacenamiento temporal que soporte la carga operativa.
	    
	
	**Tareas:**
	
	- [ ] **Benchmarking de Frameworks:** Comparar rendimiento de React vs. otras opciones para la visualización de los 4 tipos de tableros.
	    
	- [ ] **Análisis de Concurrencia en Backend:** Investigar el manejo de "Worker Threads" en Node.js frente a "Multiprocessing" en Python para el procesamiento de archivos pesados.
	    
	- [ ] **Prueba de Concepto (PoC) WebSockets:** Investigar librerías (como Socket.io o FastAPI WebSockets) que aseguren la comunicación bidireccional entre el agente de IA y el usuario.
	    
	- [ ] **Definición de Arquitectura de Datos:** Proponer si los archivos se procesarán en memoria o mediante almacenamiento temporal (BBDD no relacionales vs. relacionales).


## Pendiente



## Haciendo (Doing)



## Listo (Done)





%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,false,false]}
```
%%