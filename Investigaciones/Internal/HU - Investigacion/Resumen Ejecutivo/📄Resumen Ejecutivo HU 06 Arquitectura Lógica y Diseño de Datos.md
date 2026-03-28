## 1. Arquitectura de N-Capas (Diseño Lógico)

Se propone una estructura de 4 capas desacopladas para permitir la intercambiabilidad de componentes (como cambiar de un modelo de IA a otro) sin afectar el núcleo del negocio:

- **Capa de Presentación (Frontend):** Desarrollada en **React**, gestiona la interacción del usuario y visualiza reportes.
    
- **Capa de Orquestación y API (Backend):** Basada en **NestJS**, actúa como el cerebro que gestiona autenticación, WebSockets y comunicación con n8n.
    
- **Capa de Negocio e Inteligencia:** Aloja los Agentes de IA (Gemini/Llama 4) y flujos de limpieza (OpenRefine/TOON).
    
- **Capa de Datos:** Repositorio central para metadatos, versiones y perfiles.
    

---

## 2. Modelo de Datos y Trazabilidad (DER)

El esquema relacional está diseñado para soportar el versionamiento de los datos procesados, asegurando que cada cambio realizado por la IA sea auditable:

- **Usuarios:** Gestiona credenciales (hash), nombres y roles.
    
- **Proyectos:** Vincula a los usuarios con sus espacios de trabajo y descripciones.
    
- **Archivos Originales:** Almacena la ruta en el VPS, tamaño y tipo de archivo cargado (MIME type).
    
- **Versiones ETL:** Registra el historial de transformaciones en formato **JSON**, el estado del proceso y el número de versión.
    

---

## 3. Eficiencia y Metadatos para la IA

Para evitar el procesamiento innecesario de grandes volúmenes de texto, el sistema extrae **metadatos mínimos** para alimentar a la IA:

- **Estructura y Calidad:** Nombres de columnas, tipos de datos y conteo de valores nulos o duplicados.
    
- **Muestra y Estadísticas:** Primeras/últimas 5 filas para contexto semántico, junto con media, mediana y desviación estándar.
    
- **Cardinalidad:** Identificación de valores únicos en columnas categóricas.
    

---

## 4. Reglas de Negocio e Indicadores de Desempeño (KPIs)

El sistema debe operar bajo restricciones técnicas estrictas para garantizar una experiencia de usuario fluida:

- **Límites de Carga:** Máximo **200MB** para archivos CSV y **50MB** para Excel.
    
- **Tiempos de Respuesta:** La interacción conversacional no debe exceder los **3 segundos**.
    
- **Generación de Tableros:** El reporte final debe estar listo en menos de **30 segundos** tras la limpieza.
    
- **Seguridad:** Obligatoriedad de anonimizar datos sensibles antes de enviarlos a la capa de IA.
    

---

## 5. Flujo de Secuencia: Limpieza Asistida

El proceso ETL sigue un flujo lógico coordinado entre la interfaz y el motor de análisis:

1. **Carga:** El usuario sube el archivo desde la UI.
    
2. **Análisis:** El Backend almacena temporalmente y envía los metadatos de "salud del dato" a la IA.
    
3. **Sugerencia:** La IA devuelve recomendaciones de limpieza que se muestran en el Chatbot.
    
4. **Ejecución:** Tras la aceptación del usuario, el Backend ejecuta la transformación física y crea una nueva entrada en la tabla de **Versiones_ETL**.
    

---

## 💡 También tener en cuenta

Basado en la integración de ambas investigaciones, es crucial no olvidar:

1. **Contrato de Datos Estricto:** Se debe utilizar el estándar JSON definido para que el intercambio entre el Backend (David) y el Frontend (Oscar) sea transparente, incluyendo el `quality_score` y la optimización de tokens `toon_optimization`.
    
2. **Procesamiento por Hilos:** Si el archivo supera los **5MB**, es mandatorio activar los **Worker Threads** para evitar el bloqueo del servidor, tal como se definió en las fases de investigación previas.
    
3. **Persistencia de Prompts:** Para una trazabilidad completa, se debe almacenar el `Prompt_Utilizado` en cada versión procesada, permitiendo entender exactamente qué instrucción dio origen a cada transformación de datos.