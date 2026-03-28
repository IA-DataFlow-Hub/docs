**Fecha:** 10 de marzo de 2026

**Responsables:** Oscar Antury Avila / María Virginia Labarca

**Estado:** Auditoría de Prototipo y Diseño de Interfaz

## 1. Auditoría del Prototipo Actual

Se analizó la plataforma [ia-dataflow.codigolimpio.com.co](https://ia-dataflow.codigolimpio.com.co/) identificando oportunidades de mejora críticas:

- **Punto de Dolor 1:** Falta de feedback visual durante la carga de archivos grandes (>50k registros). El usuario no sabe si el proceso falló o continúa.
    
- **Punto de Dolor 2:** La navegación entre tableros no diferencia claramente el perfil del usuario (Gerente vs. Operativo).
    
- **Mejora sugerida:** Implementar _Skeleton Screens_ y una barra de progreso vinculada a los WebSockets de la HU 03.
    

---

## 2. Definición de los 4 Tableros (KPIs)

Para que la herramienta sea útil a nivel empresarial, se definen las siguientes visualizaciones:

|**Tablero**|**Público Objetivo**|**KPI Principal**|**Librería Sugerida**|
|---|---|---|---|
|**Estratégico**|Gerencia / CEO|Resumen de ahorro en costos y eficiencia de datos.|**Recharts** (Simple)|
|**Táctico**|Directores de Área|Tendencias de calidad de datos por departamento.|**Chart.js** (Flexible)|
|**Técnico**|Ingenieros / DBAs|Tasa de error, duplicados y salud de la DB.|**D3.js** (Complejo)|
|**Operativo**|Analistas de Datos|Estado de procesos de limpieza en tiempo real.|**TanStack Table**|

---

## 3. Herramientas de Visualización Seleccionadas

- **Recharts:** Elegida por su integración nativa con React (HU 03) y facilidad para crear gráficos responsivos. [Ver Recharts](https://recharts.org/)
    
- **D3.js:** Se reservará exclusivamente para el tablero técnico donde se requieran visualizaciones de relaciones de datos complejas. [Ver D3.js](https://d3js.org/)
    

---

## 4. Gestión de Colaboradores y Tiempo Real

Para permitir el trabajo en equipo (Empresas grandes), se propone:

- **Roles:** _Admin_ (Configuración), _Editor_ (Limpieza de datos) y _Viewer_ (Solo lectura de Dashboards).
    
- **Estados Compartidos:** Uso de **Zustand** o **Redux** para asegurar que si un usuario limpia un dato, el resto del equipo vea el cambio reflejado instantáneamente sin recargar la página. [Ver Zustand](https://zustand-demo.pmnd.rs/)
    

---

## 5. Conclusión / Recomendación

Se recomienda rediseñar el flujo de carga integrando un "Asistente de IA" que guíe al usuario. María Virginia (Soporte) validará que la interfaz sea intuitiva para personal no técnico, mientras Oscar (Multimedia) asegura que los gráficos de **Recharts** sean interactivos y exportables a PDF/Excel.