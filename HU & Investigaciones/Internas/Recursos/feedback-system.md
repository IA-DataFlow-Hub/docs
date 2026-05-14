# Sistema de Feedback  
## Validación de botones 👍👎 y reporte de errores  
IA-DataFlow-Hub  

---

## 1. Objetivo  
Definir la lógica de validación del sistema de feedback para garantizar interacciones correctas entre el usuario y las respuestas de la IA.

---

## 2. Tipos de feedback  
- 👍 Pulgar arriba (respuesta válida)  
- 👎 Pulgar abajo (respuesta no válida)  
- 🚨 Reporte de error (fallo en la respuesta o sistema)  

---

## 3. Reglas de validación  

- Solo usuarios autenticados pueden enviar feedback  
- El feedback debe estar asociado a un mensaje válido (message_id existente)  
- Solo se permite un feedback por usuario por mensaje  
- No se permite enviar feedback sin sesión activa  
- No se permite enviar feedback sobre mensajes eliminados  
- No se permite modificar feedback directamente; cualquier cambio debe registrarse como una nueva acción del usuario  

---

## 4. Lógica de validación  

### 👍 Pulgar arriba  
- Se valida autenticación del usuario  
- Se valida existencia del mensaje  
- Si no existe feedback previo, se registra como positivo  
- Si existe feedback previo, se actualiza a positivo  
- No se permiten registros duplicados  

---

### 👎 Pulgar abajo  
- Se valida autenticación del usuario  
- Se valida existencia del mensaje  
- Si no existe feedback previo, se registra como negativo  
- Si existe feedback previo, se actualiza a negativo  
- No se permiten registros duplicados  

---

### 🚨 Reporte de error  
- Se valida autenticación del usuario  
- Se valida existencia del mensaje  
- Se registra un único reporte por usuario y mensaje  
- El reporte queda asociado al mensaje correspondiente  
- Se genera registro para revisión del sistema  

---

## 5. Resultado esperado  
- Control de feedback sin duplicados  
- Validación de autenticación y existencia de mensajes  
- Trazabilidad de la interacción usuario–IA  

