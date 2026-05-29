# HU 106 - Revisión y Validación de Pruebas de Integración Existentes

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Alta

---

## HU-106: Revisión y validación de pruebas de integración existentes

**Como** responsable de calidad del proyecto,
**quiero** revisar todas las pruebas de integración ya implementadas (HU-056 a HU-067) y validar que siguen siendo correctas con el estado actual del código,
**para** asegurar que los módulos ya entregados no tienen regresiones y detectar gaps en módulos nuevos que aún no tienen pruebas.

### Criterios de Aceptación

#### Ejecución y verificación
- El sistema debe ejecutar `npm run test` en `apps/api` y todos los spec deben pasar sin errores
- El sistema debe ejecutar `npm run test:cov` y reportar el porcentaje de cobertura por módulo
- El sistema debe documentar en un archivo `docs/QA/reporte-integracion.md` los resultados: módulo, tests pasados, tests fallidos, cobertura %

#### Revisión de HUs de testing existentes
- El sistema debe revisar cada una de las HUs HU-056 a HU-067 y verificar que los escenarios documentados en ellas corresponden con los tests implementados
- El sistema debe marcar en el reporte qué escenarios de cada HU tienen test y cuáles no
- El sistema debe identificar si hay tests que prueban comportamiento que ya no existe en el código (tests obsoletos)

#### Módulos sin cobertura de pruebas de integración
- El sistema debe identificar que los módulos `projects`, `audit`, y `llm-gateway` (HU-097 a HU-105) no tienen HUs de testing asignadas aún
- El sistema debe crear un listado de endpoints sin cobertura de test como insumo para HU-107 y HU-108

### Entregables
- `docs/QA/reporte-integracion.md` con: resumen de ejecución, cobertura por módulo, gaps identificados, endpoints sin test

### Notas
- Los spec existentes están en `apps/api/src/modules/*/infrastructure/controllers/*.spec.ts` y `application/use-cases/*.spec.ts`
- 30 archivos spec existentes — verificar que todos se ejecuten correctamente con el schema de DB actual
