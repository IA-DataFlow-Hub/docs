**Responsables:** Sebastián Bautista / Andrés Felipe Andrade
**Estado:** Investigación de Viabilidad

## 1. Cuadro Comparativo de Proveedores (VPS)

Se evaluaron configuraciones base de **4GB RAM / 2 vCPU** para soportar Node.js y procesos de IA en segundo plano.

|**Proveedor**|**Plan Sugerido**|**Precio Mensual (USD)**|**Enlace de Referencia**|
|---|---|---|---|
|**DigitalOcean**|Basic Droplet (Premium Intel)|$28.00|[Ver Precios](https://www.digitalocean.com/pricing/droplets)|
|**AWS**|Lightsail (Instancia Estándar)|$20.00|[Ver Precios](https://aws.amazon.com/es/lightsail/pricing/)|
|**Hostinger**|VPS KVM 2|$7.99*|[Ver Precios](https://www.hostinger.co/vps-hosting)|

> [!NOTE]
> 
> _Hostinger requiere pago trienal para mantener ese precio. AWS y DigitalOcean ofrecen facturación por hora, ideal para escalabilidad inmediata._

---

## 2. Validación Técnica

- **Soporte Node.js/Python:** Los tres proveedores ofrecen imágenes oficiales de **Ubuntu 22.04/24.04**, facilitando el despliegue de entornos mediante Docker o PM2.
    
- **WebSockets:** Confirmado el soporte de conexiones persistentes mediante configuración de **Nginx como Reverse Proxy**. No hay restricciones de protocolo en estos VPS.
    
- **Escalabilidad:** * **AWS/DigitalOcean:** Escalado vertical (Upgrade de RAM/CPU) con solo un reinicio.
    
    - **Hostinger:** Escalado limitado a planes predefinidos.
        

---

## 3. Latencia y Conectividad

Para empresas en **Colombia**, se recomiendan los centros de datos en **EE. UU. Este (Virginia / Ohio)**.

- **Latencia Promedio:** 60ms - 90ms.
    
- **Recomendación:** AWS Lightsail en la región `us-east-1` por su integración con el backbone global, asegurando respuesta rápida para el Chatbot.
    

---

## 4. Conclusión / Recomendación

Se sugiere iniciar con **DigitalOcean (Premium Intel)** o **AWS Lightsail**. Aunque son más costosos que Hostinger, su estabilidad de red y facilidad para manejar **WebSockets** y procesos pesados de IA justifican la inversión para el prototipo profesional.