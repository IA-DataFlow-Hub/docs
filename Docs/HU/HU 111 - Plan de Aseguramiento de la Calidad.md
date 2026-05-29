# HU 111 - Plan de Aseguramiento de la Calidad (QA Plan)

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Alta
> **Depende de:** HU-106, HU-107, HU-108, HU-109, HU-110

---

## HU-111: Crear plan de aseguramiento de la calidad para integraciones del equipo

**Como** responsable de calidad del proyecto,
**quiero** crear un plan de QA formal que defina los criterios y el proceso que debe cumplir cualquier módulo o feature antes de ser integrado al branch principal,
**para** que el equipo tenga una guía clara, el código mantenga estándares consistentes y no se rompan funcionalidades existentes con cada integración.

### Criterios de Aceptación

#### Documento: Plan de Pruebas (`docs/QA/plan-pruebas.md`)
El documento debe cubrir:

**1. Alcance y objetivos**
- Qué módulos y funcionalidades cubre el plan
- Criterios de entrada (qué debe tener un feature para entrar a QA)
- Criterios de salida (qué debe cumplir para ser aprobado)

**2. Tipos de prueba y responsables**

| Tipo | Quién | Cuándo | Herramienta |
|------|-------|--------|-------------|
| Pruebas unitarias | Desarrollador | Antes de PR | Jest (`npm run test`) |
| Pruebas de caja blanca | QA (Pohlman) | Review de PR | Jest + lectura de código |
| Pruebas de caja negra | QA (Pohlman) | Post-merge a develop | Swagger UI |
| Pruebas de integración | Desarrollador + QA | Post-merge | Jest + Swagger |
| Revisión de documentación | QA (Pohlman) | Review de PR | Manual |

**3. Checklist de revisión de PR** (checklist que QA aplica a cada Pull Request)
- [ ] Los spec.ts pasan sin errores (`npm run test`)
- [ ] Cobertura de tests no bajó respecto al branch anterior
- [ ] Nuevos endpoints tienen decoradores Swagger completos
- [ ] No hay código comentado, `console.log`, ni secrets hardcodeados
- [ ] Use-cases no importan directamente de Prisma
- [ ] Controllers solo delegan al facade (sin lógica de negocio)
- [ ] Errores de dominio tienen excepción tipada
- [ ] Variables de entorno nuevas están documentadas en `.env.example`
- [ ] HU correspondiente tiene criterios de aceptación verificados

**4. Métricas de calidad mínimas**

| Métrica | Mínimo aceptable |
|---------|-----------------|
| Cobertura de tests por módulo | 70% |
| Endpoints sin documentación Swagger | 0 |
| Errores críticos en reporte de calidad | 0 |
| Errores de seguridad (SQL injection, secrets) | 0 |

**5. Proceso de reporte de defectos**
- Issues en GitHub con labels: `bug` (funcional), `quality` (calidad técnica), `security` (seguridad)
- Severidad: `critical` (bloquea deploy), `high` (debe resolverse en sprint), `medium`, `low`
- Template de issue a usar para defectos encontrados en QA

**6. Proceso de integración con el branch principal**

```
feature/xxx → develop (PR + checklist QA) → main (solo código que pasó QA)
```

- Todo PR a `develop` requiere aprobación de QA (review de Pohlman)
- Ningún PR a `main` sin haber pasado las pruebas de caja negra en `develop`

**7. Plan de pruebas para módulos pendientes**
Basado en los reportes de HU-106 a HU-110, priorizar:
- HUs de testing para módulos `projects`, `audit`, `llm-gateway` (no tienen spec aún)
- Escenarios de integración entre módulos (ej: crear proyecto → triggear AI job)

#### Documento: `docs/QA/README.md`
Índice de todos los reportes y documentos de QA generados, con links a:
- `plan-pruebas.md` (este documento)
- `reporte-integracion.md` (HU-106)
- `reporte-caja-negra.md` (HU-107)
- `reporte-caja-blanca.md` (HU-108)
- `reporte-calidad-codigo.md` (HU-109)
- `reporte-swagger.md` (HU-110)

### Entregables
- `docs/QA/plan-pruebas.md` — documento completo
- `docs/QA/README.md` — índice del directorio QA
- PR template en `.github/PULL_REQUEST_TEMPLATE.md` con el checklist de QA embebido

### Notas
- Este plan es un documento vivo — debe actualizarse cuando se agreguen módulos nuevos
- El checklist de PR es la herramienta más importante: hace que la calidad sea parte del flujo de trabajo, no una actividad separada
- Depende de los reportes de HU-106 a HU-110 para tener datos reales de la situación actual del proyecto
