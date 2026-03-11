> [!abstract] **Resumen Ejecutivo** Este documento técnico establece las bases del sistema de **ETL y Visualización con IA**. Define qué debe hacer el software (RF), bajo qué restricciones operará (RNF) y cómo se estructurará mediante diagramas UML, asegurando que cualquier usuario pueda obtener _insights_ de alto valor sin conocimientos profundos de analítica.

---

## 📋 Especificaciones del Sistema

## 1. Requerimientos Funcionales (RF)

- **Carga de Datos:** El sistema debe permitir subir archivos en formatos comunes (CSV, Excel).
    
- **Procesamiento IA:** Integración de modelos LLM para realizar la limpieza y transformación automática de datos.
    
- **Visualización Inteligente:** Generación de gráficos dinámicos basados en las consultas del usuario.
    
- **Gestión de Usuarios:** Registro, inicio de sesión y persistencia de proyectos anteriores.
    

## 2. Requerimientos No Funcionales (RNF)

- **Seguridad:** Protección de datos sensibles mediante protocolos de cifrado.
    
- **Escalabilidad:** Capacidad para manejar incrementos en el volumen de datos sin degradar el rendimiento.
    
- **Usabilidad:** Interfaz intuitiva diseñada para usuarios no técnicos.
    

---

## 📐 Diseño de Arquitectura (UML)

El documento utiliza el estándar UML para modelar la solución:

- **Diagramas de Casos de Uso:** Define las interacciones entre el Usuario y el Sistema (Carga de datos ➡️ Procesamiento ➡️ Visualización).
    
- **Diagramas de Clases:** Estructura de los objetos del sistema (Usuario, Proyecto, Dataset, Visualización).
    
- **Diagramas de Secuencia:** El orden lógico de los mensajes entre componentes para ejecutar el flujo ETL.
    

---

## 🚀 Aplicación Estratégica en el FUUA Team

> [!success] **Guía de Desarrollo**
> 
> - **Full Stack (.NET/Angular):** **David Ospina** debe usar los diagramas de clases para diseñar el modelo de datos en **MySQL** y los RF para construir los endpoints en el backend.
>     
> - **Infraestructura:** **Sebastián Bautista** debe basarse en los RNF para configurar los servidores en la nube y asegurar la alta disponibilidad.
>     
> - **Frontend:** **Brayan Monterrosa** usará los diagramas de casos de uso para diseñar los flujos de navegación y la experiencia de carga de archivos.
>     

---

## 🔍 Conclusión de la Investigación

La investigación concluye que es totalmente viable desarrollar una solución web que combine **IA + ETL**, permitiendo democratizar el acceso a la analítica de datos técnica para personas de todas las áreas (estudiantes, trabajadores, etc.).

---

## 📂 Referencia del Documento

- **Archivo Original:** [[RF y RNF DIAGRAMAS UML - ETL - IA.pdf]]
    
- **Responsables:** Raúl Bareño Gutiérrez (Director)
    
- **Docente Tutor:** Profesor Raúl Bareño Gutiérrez
    
- **Categoría:** 🏗️ Ingeniería / Arquitectura de Software
    
- **Fecha de Análisis:** 2026-03-07