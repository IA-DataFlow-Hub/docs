# HU 077 - Conectar Formulario de Registro con la API

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075

---

## HU-077: Conectar formulario de Registro con la API

**Como** usuario nuevo,
**quiero** que al enviar el formulario de Registro se llame a `POST /auth/register` con mis datos,
**para** crear una cuenta real en el sistema.

### Criterios de Aceptación
- El sistema debe leer los campos: nombre completo, empresa, email, contraseña y confirmar contraseña de `Register.tsx`
- El sistema debe validar en cliente que las contraseñas coincidan antes de enviar la petición
- El sistema debe llamar a `POST /auth/register` con los datos del formulario
- El sistema debe redirigir a `/login` tras registro exitoso mostrando un mensaje de éxito
- El sistema debe mostrar errores de la API bajo el campo correspondiente (ej: "El email ya está registrado")
- El sistema debe mostrar indicador de carga en el botón durante la petición

### Notas
- Actualmente `handleRegister` en `Register.tsx` solo navega sin validar — reemplazar esa lógica
- El campo "empresa" puede mapearse a un campo de perfil del usuario según contrato de la API
- Depende de HU-075
