# Protocolo de Seguridad  
## Acceso por Roles y Gestión de Sesiones  
IA-DataFlow-Hub  

---

## 1. Objetivo  
Definir las validaciones de seguridad para el control de acceso por roles y la gestión de sesiones de usuario dentro del sistema.

---

## 2. Control de acceso por roles  

El sistema maneja dos roles principales:

| Rol | Descripción |
|-----|-------------|
| Administrador (Admin) | Gestión de usuarios, equipos, proyectos y configuración del sistema |
| Usuario | Acceso limitado a recursos y proyectos autorizados |

---

## 3. Validaciones por rol  

### 3.1 Administrador  

**Permisos:**
- Gestión de usuarios  
- Asignación de roles  
- Administración de proyectos  
- Acceso a auditorías  

**Restricciones:**
- No acceso sin autenticación válida  
- No uso de tokens expirados  
- No ejecución de acciones sin permisos asignados  

---

### 3.2 Usuario  

**Permisos:**
- Acceso a proyectos propios  
- Subida de archivos  
- Uso de funcionalidades de IA  

**Restricciones:**
- No acceso a datos de otros usuarios  
- No modificación de roles o permisos  
- No acceso a módulos administrativos  

---

## 4. Gestión de sesiones  

| Elemento | Duración |
|----------|----------|
| Access Token | 15 minutos |
| Refresh Token | 7 días |

---

### Validaciones de sesión  
- Renovación automática mediante refresh token válido  
- Bloqueo de acceso con token expirado  
- Cierre de sesión invalida inmediatamente todos los tokens  
- Los tokens inválidos no pueden reutilizarse  
- Cambio de contraseña invalida todas las sesiones activas  

---

## 5. Resultado esperado  
- Control de acceso seguro basado en roles  
- Separación de privilegios entre usuarios  
- Gestión segura de sesiones activas  
- Prevención de accesos no autorizados  
