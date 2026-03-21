## 1. Cumplimiento Normativo (Ley 1581)

El sistema se diseña bajo el principio de **Privacidad desde el Diseño**, cumpliendo con las directrices de la Superintendencia de Industria y Comercio (SIC):

- **Autorización Informada:** Es obligatorio obtener el consentimiento previo, expreso y verificable del titular antes de procesar cualquier dato.
    
- **Finalidad Definida:** Los datos solo se usarán para lo informado (ETL y visualización). Cualquier otro uso requiere una nueva autorización.
    
- **Datos Sensibles y Menores:** El tratamiento de salud, biometría o datos de niños tiene protección reforzada y requiere autorización explícita del representante legal.
    

## 2. Mecanismo de Consentimiento y Transparencia

Para evitar sanciones (que pueden llegar a 2,000 SMMLV), se implementará un flujo técnico de auditoría:

- **Registro de Consentimiento:** No basta con un "aceptar". Se guardará un log técnico: `User_ID`, `Fecha/Hora`, `IP`, y `Versión de la política`.
    
- **Derechos ARCO:** El usuario tendrá botones visibles en su perfil para **Eliminar mis datos** o **Revocar consentimiento** de forma inmediata.
    

## 3. Seguridad Técnica y Cifrado 🔐

Para garantizar que los archivos (CSV/Excel) viajen seguros, se establecen medidas de "endurecimiento" (_Hardening_):

- **Cifrado en Tránsito:** Uso obligatorio de **SSL/TLS (Let's Encrypt)**. Se desactivarán protocolos obsoletos (TLS 1.0/1.1) permitiendo solo versiones 1.2 y 1.3.
    
- **Seguridad del Servidor (VPS):**
    
    - Deshabilitar acceso _root_ y cambiar el puerto SSH (del 22 a uno personalizado).
        
    - Uso exclusivo de llaves SSH (RSA 4096 bits), prohibiendo contraseñas.
        
    - Firewall estricto (UFW) cerrando todo puerto no esencial.
        

## 4. Política de "Borrado Cero" (Data Retention)

Para cumplir con el principio de finalidad, los datos personales no residirán permanentemente en el servidor:

- **Borrado Inmediato:** Al cerrar la sesión o tras 60 minutos de inactividad.
    
- **Tarea Programada (Cron Job):** El servidor ejecutará un proceso cada hora para eliminar cualquier archivo en `/tmp/uploads/` con más de 2 horas de antigüedad.
    
- **Entrenamiento de IA:** Se aclara que los datos enviados vía API (Gemini/Llama 4) **no se utilizarán para entrenar modelos externos**, garantizando la propiedad intelectual y privacidad del usuario.
    

---

## ⚠️ También tener en cuenta

Para un blindaje total del proyecto, es fundamental considerar estos tres pilares adicionales:

1. **Ley 1273 de 2009 (Ley de Delitos Informáticos):** No solo debemos proteger los datos, sino prevenir delitos como el "Acceso abusivo a un sistema informático" o la "Interceptación de datos". Es vital implementar sistemas de detección de intrusos (IDS) para cumplir con esta ley penal colombiana.
    
2. **Circular Única de la SIC (Título V):** Si el proyecto escala a nivel empresarial, se debe verificar si la organización está obligada a inscribir las bases de datos en el **RNBD (Registro Nacional de Bases de Datos)**, lo cual es un requisito administrativo adicional a la Ley 1581.
    
3. **Gestión de Incidentes (Art. 17, literal n):** En caso de una brecha de seguridad (hackeo), la ley obliga a informar a la SIC y a los titulares en un plazo máximo de **15 días hábiles**. Debes tener un "Protocolo de Respuesta a Incidentes" redactado y listo para actuar.