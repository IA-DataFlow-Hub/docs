# HU 109 - Lectura de Código y Análisis de Calidad

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Alta

---

## HU-109: Lectura de código y análisis de calidad técnica

**Como** responsable de calidad del proyecto,
**quiero** leer el código fuente de los módulos principales y evaluar su calidad técnica,
**para** identificar code smells, violaciones de arquitectura, inconsistencias y oportunidades de mejora antes de que el código llegue a producción.

### Criterios de Aceptación

#### Criterios de evaluación por módulo
Revisar cada módulo del API con los siguientes ojos:

**Clean Architecture**
- ¿Las entidades de dominio tienen dependencias de infraestructura? (no deberían)
- ¿Los use-cases importan directamente de Prisma en lugar de pasar por el repositorio? (no deberían)
- ¿Los controllers tienen lógica de negocio? (no deberían — solo delegar al facade)

**Convenciones de código**
- Nombres de variables, funciones y clases son descriptivos y consistentes con el resto del proyecto
- No hay código comentado sin razón (`// TODO` sin fecha, código muerto)
- No hay `console.log` ni `console.error` en código de producción (solo el logger oficial)

**Manejo de errores**
- Todos los errores de dominio tienen su excepción tipada (no `throw new Error("string")` genérico)
- Los controllers no swallean excepciones silenciosamente
- Los repositorios traducen errores de Prisma a excepciones de dominio

**Seguridad básica**
- No hay queries SQL raw con interpolación de strings (riesgo de SQL injection)
- No hay tokens, passwords ni secrets hardcodeados
- Los endpoints sensibles tienen guard aplicado (`JwtAuthGuard`, `PermissionsGuard`)

#### Módulos a revisar
- `auth`, `users`, `teams`, `projects`, `tasks`, `notifications`, `ai-jobs`, `audit`, `conversations`

#### Documentar hallazgos
- Crear `docs/QA/reporte-calidad-codigo.md` con tabla: Archivo | Línea | Severidad (Alta/Media/Baja) | Problema | Sugerencia
- **Severidad Alta**: violación de seguridad, error que puede causar crash en producción
- **Severidad Media**: violación de arquitectura, acoplamiento incorrecto
- **Severidad Baja**: naming inconsistente, código muerto, mejora de legibilidad

### Entregables
- `docs/QA/reporte-calidad-codigo.md`
- Issues en GitHub para hallazgos de severidad Alta y Media con label `quality` y `technical-debt`

### Notas
- No modificar código en esta HU — solo reportar. Los fixes se priorizan en sprint siguiente
- Usar como referencia el estándar Clean Architecture ya establecido en el proyecto (ver `teams` como módulo de referencia bien implementado)
