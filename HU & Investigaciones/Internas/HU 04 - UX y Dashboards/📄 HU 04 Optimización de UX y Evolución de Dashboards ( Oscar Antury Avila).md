![[HU 03 y HU 04.pdf]]
# 📊 HU 04: Optimización de UX y Evolución de Dashboards

## 1. Bibliotecas de gráficos para los tableros

| **Biblioteca** | **Integración**           | **Ventajas**                                                           | **Uso recomendado**                                                         |
| -------------- | ------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **Recharts**   | React                     | Componentes modulares, fácil de usar, soporte para animaciones básicas | Dashboards estándar y visualizaciones comunes                               |
| **D3.js**      | JS (integrable con React) | Personalización avanzada, animaciones complejas                        | Visualizaciones específicas y flujos de datos personalizados                |
| **ApexCharts** | React                     | Interactivo, múltiples series, tooltips avanzados, gráficos combinados | Dashboards con interactividad moderada y múltiples tipos de gráficos        |
| **Plotly.js**  | JS / React                | Gráficos avanzados, 3D, interactividad compleja                        | Dashboards con análisis de datos sofisticados o visualizaciones científicas |

---

## 2. Flujo de Gestión de Colaboradores (Invitaciones y Roles)

- **Invitación:** registro de correo electrónico vinculado a una organización.
    
- **Roles:**
    
    - **Lector:** acceso de solo lectura a métricas.
        
    - **Analista:** creación de flujos y modificación de tableros.
        
    - **Administrador:** gestión de usuarios, roles y credenciales de API.
        
- **Seguridad:** uso de tokens JWT con expiración para garantizar acceso temporal hasta completar el registro.
    

---

## 3. Manejo de Estados Compartidos en Tiempo Real

Para habilitar la colaboración simultánea en los dashboards se propone:

- **WebSockets (Socket.io):** comunicación bidireccional que permite enviar actualizaciones de KPIs a todos los usuarios conectados sin recargar la página.
    
- **Zustand:** librería de gestión de estado en React que sincroniza acciones de los usuarios (por ejemplo, aplicar filtros) en tiempo real.
    
- **Costo de infraestructura:** implementación en un VPS básico (ej. DigitalOcean) con un costo aproximado de **$6–$12 USD/mes**.
    
    - _Fuente:_ [DigitalOcean Pricing](https://www.digitalocean.com/pricing/droplets)
        

---

## 4. Auditoría del Prototipo: Puntos de Dolor

Tras la inspección técnica de `ia-dataflow.codigolimpio.com.co` se identificaron los siguientes problemas:

> [!CAUTION] Hallazgos Técnicos
> 
> - **Interactividad limitada:** los gráficos funcionan como elementos estáticos y no permiten filtrado cruzado entre componentes.
>     
> - **Tablas densas:** el Dashboard 2 presenta tablas de datos sin virtual scrolling ni paginación eficiente, afectando el rendimiento al manejar grandes volúmenes de registros.
>     
> - **Falta de feedback operativo:** ausencia de notificaciones visuales (Toasts o Snackbars) al ejecutar acciones administrativas o de configuración.
>     

---

## 5. Sustento Legal

La gestión de colaboradores debe cumplir con la **Ley 1581 de 2012** sobre Protección de Datos Personales en Colombia, incluyendo avisos de privacidad y manejo seguro de información de contacto.

- _Fuente:_ [Funcionpublica.gov.co - Ley 1581](https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=49981)