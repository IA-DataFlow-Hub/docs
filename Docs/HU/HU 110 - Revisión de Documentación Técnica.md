# HU 110 - Revisión de Documentación Técnica

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Media

---

## HU-110: Revisión de documentación técnica — Swagger, HUs e instrucciones de setup

**Como** responsable de calidad del proyecto,
**quiero** revisar toda la documentación técnica del proyecto y verificar que sea precisa, completa y consistente con el código implementado,
**para** que cualquier miembro del equipo o evaluador pueda entender y usar el sistema correctamente.

### Criterios de Aceptación

#### Swagger UI (`/api/docs`)
- Verificar que **todos** los endpoints tienen `@ApiOperation` con descripción
- Verificar que todos los request bodies tienen `@ApiBody` con esquema y ejemplos
- Verificar que los responses documentados (`@ApiResponse`) coinciden con los que el código realmente retorna
- Verificar que los campos marcados como requeridos en el DTO son realmente requeridos
- Detectar endpoints que NO aparecen en Swagger (sin `@ApiTags`) — especialmente módulos nuevos: `projects`, `audit`
- Documentar en `docs/QA/reporte-swagger.md`: Endpoint | ¿Tiene descripción? | ¿Body documentado? | ¿Responses correctos? | Observaciones

#### Historias de Usuario (`docs/HU/`)
- Revisar que los criterios de aceptación de las HUs de los módulos ya implementados corresponden con el comportamiento real del código
- Identificar HUs cuyo alcance cambió durante implementación y que requieren actualización
- Verificar que las HUs de testing (HU-056 a HU-067) reflejan los escenarios reales

#### Documentación de setup (`README.md`, `docs/SETUP.md`)
- Seguir las instrucciones de instalación desde cero en una terminal limpia
- Verificar que `docker-compose up` levanta correctamente todos los servicios
- Verificar que las variables de entorno documentadas son correctas y completas
- Verificar que las instrucciones de seed de BD funcionan

#### Instrucciones de hu-cli (`docs/packages/hu-cli.md`)
- Verificar que los comandos documentados (`hu list`, `hu priority`, `hu size`, `hu assign`) funcionan como describe la documentación
- Verificar que los ejemplos de rangos (`42-51`) funcionan correctamente

### Entregables
- `docs/QA/reporte-swagger.md`
- `docs/QA/reporte-documentacion.md` con hallazgos en HUs y README
- PRs de corrección para inconsistencias menores encontradas (no esperar sprint siguiente para correcciones de docs)

### Notas
- Foco especial en módulos añadidos recientemente: `projects`, `audit`, `llm-gateway` — son los que más riesgo tienen de documentación incompleta
