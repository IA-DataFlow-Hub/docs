# 📝 Acta de Reunión: Proyecto IA-DataFlow

**Fecha:** 07 de marzo de 2026

**Participantes:** Profesor Raúl Bareño, Ing. Juan Diego (Grupo 1), Ing. David (Grupo 2), María, Sebastián, Óscar, Brian y Pohlman.

---

## 🖥️ 1. Explicación de los Prototipos Presentados

#### **Propuesta Grupo 1 (Ing. Juan Diego - Desarrollado en React)**

El ingeniero Juan presentó un prototipo interactivo con un enfoque en la experiencia de usuario y arquitectura escalable:

- **Interfaz de Usuario:** Página principal orientada a la venta del servicio para empresas de todo tamaño, con un sistema de **Login y Registro**.
    
- **Flujo de 4 Fases:**
    
    1. **Diseñar:** Carga de documentos.
        
    2. **Ejecutar:** El chat propone ideas y el usuario las acepta.
        
    3. **Supervisar:** Revisión de cambios realizados.
        
    4. **Optimizar:** Aplicación de buenas prácticas para mejorar el rendimiento.
        
- **Vistas Especializadas:** * **Chat Conversacional:** Interacción directa con la IA.
    
    - **Historial de Cambios:** Permite comparar versiones, editar o revertir cambios (ej. cambios de formato de fecha o eliminación de duplicados).
        
    - **Estructura y Datos:** Visualización de tablas, tipos de datos y validaciones.
        
    - **Diagrama Relacional:** Mapa conceptual gráfico de cómo se conectan los archivos cargados.
        
    - **Reportes y Templates ETL:** Uso de **n8n** para aplicar flujos predefinidos (normalización de datos) y generación de reportes automáticos.
        

#### **Propuesta Grupo 2 (Ing. David - Desarrollado en Figma)**

El equipo 2 presentó un flujo enfocado en la simplicidad operativa y la interacción directa:

- **Enfoque:** Análisis poblacional y dashboards de visualización.
    
- **Interacción:** Un chat que guía al usuario desde el inicio de sesión hasta la carga del documento, realizando preguntas específicas sobre datos ambiguos o duplicados para su limpieza inmediata.
    

---

## 💡 2. Análisis Técnico y Debatido

- **Tecnología:** Se destacó el uso de **React** por su capacidad de respuesta en tiempo real (ejecución reactiva).
    
- **Infraestructura:** El Ing. Juan advirtió que un hosting tradicional no soportaría el tráfico masivo o la conexión de múltiples usuarios en tiempo real; se sugirió el uso de **WebSockets** y un servidor **VPS o On-Premise**.
    
- **Manejo de Datos:** Se discutió la lógica de "dividir para conquistar" (hilos/bloques) para procesar archivos pesados (más de 10,000 registros) sin bloquear el sistema.
    

---

## ✅ 3. Decisión Final y Acuerdos

En un ejercicio democrático, el equipo tomó las siguientes decisiones:

1. **Adopción de Propuesta:** Se eligió la **propuesta del Grupo 1** como base principal por estar más completa y estructurada.
    
2. **Unificación del Equipo:** Los dos grupos se fusionan en **un solo equipo de trabajo** bajo la metodología **Scrum**.
    
3. **Liderazgo y Organización:** * Se creó un grupo de WhatsApp para la comunicación inmediata.
    
    - El Ing. Juan Diego desglosará una **tabla de tareas y responsabilidades** donde cada integrante se asignará según su perfil.
        
    - Se definieron roles para investigar costos de dominio, hosting y consumo de tokens de IA.
        

---

## 📅 4. Compromisos para los próximos 15 días

Cada integrante debe presentar un **documento de investigación formal** (entregable) sobre:

- **Costos:** Presupuesto de dominio, hosting (anual) y escala de precios por consumo de tokens (desde 1,000 hasta 100,000 registros).
    
- **Herramientas:** Definición final de las mejores herramientas para el Backend y Frontend.
    
- **Proyección:** Análisis basado en una PYME real para tener un presupuesto acertado.
    

> [!important] **Nota sobre el Acta** El Ing. David se encargará de formalizar el formato de acta para la firma de los ocho integrantes del semillero, dejando constancia de la decisión democrática y el cronograma de actividades.