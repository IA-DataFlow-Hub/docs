**Fecha:** 10 de marzo de 2026

**Responsables:** Pohlman Cuartas / David Ospina

**Estado:** Marco Normativo y Protocolos de Cifrado

## 1. Marco Legal (Ley 1581 de 2012 - Colombia)

Para operar legalmente ante la **Superintendencia de Industria y Comercio (SIC)**, el sistema debe garantizar:

- **Principio de Libertad:** El tratamiento solo puede ejercerse con el consentimiento previo, expreso e informado del titular. [Ver Ley 1581](https://www.google.com/search?q=https://www.funcionpublica.gov.co/eva/gestornormativa/norma.php%3Fi%3D49981)
    
- **Principio de Finalidad:** Los datos solo se usarán para la limpieza y analítica prometida, prohibiendo usos comerciales ajenos.
    
- **Aviso de Privacidad:** Se debe implementar un _check-box_ obligatorio antes de subir cualquier archivo, vinculando a los términos y condiciones.
    

## 2. Estándares de Seguridad Técnica

Para proteger la integridad de los archivos empresariales, se definen los siguientes niveles de blindaje:

|**Capa**|**Estándar / Protocolo**|**Aplicación**|**Enlace de Referencia**|
|---|---|---|---|
|**En Tránsito**|**SSL/TLS 1.3**|Cifrado de la comunicación entre el navegador y el VPS.|[Ver TLS 1.3](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)|
|**En Reposo**|**AES-256**|Cifrado de los archivos mientras residen temporalmente en el servidor.|[Ver AES-256](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)|
|**Acceso**|**JWT (JSON Web Tokens)**|Autenticación segura de usuarios para evitar suplantación.|[Ver JWT.io](https://jwt.io/)|

## 3. Privacidad en la IA (API Ethics)

Se investigó la política de privacidad de los proveedores de IA para evitar la fuga de datos:

- **Google Gemini (Paid API):** Los datos enviados a través de la API de pago **NO** se utilizan para entrenar sus modelos globales. Los datos permanecen privados. [Ver Google Privacy](https://ai.google.dev/terms)
    
- **OpenAI (API):** Al igual que Google, los datos de la API están excluidos del entrenamiento de modelos por defecto. [Ver OpenAI Privacy](https://openai.com/enterprise-privacy/)
    

## 4. Política de Retención y Borrado

- **Borrado Automático:** Se implementará un _Cron Job_ (Tarea programada) que elimine permanentemente los archivos procesados y sus versiones temporales cada **24 horas** o al cerrar la sesión del usuario.
    
- **Logs de Auditoría:** Se registrará quién accedió a qué archivo y en qué fecha, sin guardar el contenido del archivo, para cumplir con la trazabilidad exigida por la SIC.
    

## 5. Conclusión / Recomendación

Se recomienda la implementación de un **Certificado SSL de Let's Encrypt** (Gratuito y automático) en el VPS (HU 01) y el uso de **AES-256** para archivos en el servidor. Pohlman (Seguridad Industrial) supervisará que no existan vulnerabilidades de inyección, mientras David asegura que el flujo de las APIs sea 100% privado y legal.