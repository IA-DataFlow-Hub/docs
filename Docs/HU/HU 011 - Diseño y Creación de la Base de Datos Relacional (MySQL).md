**Como** Arquitecto de Software,
**Quiero** definir y desplegar la estructura lógica de la base de datos en MySQL,
**Para** asegurar la persistencia de datos bajo un modelo normalizado y escalable que soporte la gestión de equipos y fases.

**_Criterios de Aceptación:_**

**Esquema de Tablas:** Crear las tablas users, teams, conversations, files y audit_logs.
**Relación N:M:** Implementar una tabla intermedia (ej. team_members) para vincular usuarios y equipos.
**Gestión de Fases:** La tabla conversations debe incluir un campo phase de tipo ENUM o similar con los valores: DISENAR, EJECUTAR, SUPERVISAR, OPTIMIZAR.
**Estado del Tour:** Agregar el campo has_completed_tour (boolean) en la tabla users para el seguimiento de la UX.
**Auditoría:** La tabla audit_logs debe registrar user_id, action, entity, timestamp y changes (JSON).

Tener en cuenta la pagina para hacer el modelo entidad Relacion https://ia-dataflow.codigolimpio.com.co/dashboard

[![Ver video](https://img.youtube.com/vi/voTEEV6XUKw/0.jpg)](https://www.youtube.com/watch?v=voTEEV6XUKw)




---

## 📋 Seguimiento del Proyecto

| Campo | Valor |
|---|---|
| **Tema** | Base de Datos |
| **Actividad** | HU 11: Diseño y Creación de la Base de Datos Relacional (MySQL) |
| **Entregable** | Entregable 3 |
| **Meta Numérica** | 3 |
| **Responsable(s)** | Equipo: Sebastián Bautista Martínez, María Virginia Labarca, Andres Felipe Andrade |
| **Fecha Inicio** | 3/05/2026 |
| **Fecha Fin** | 9/05/2026 |
| **Fecha Entrega** | 9/06/2026 |
| **Riesgo** | Media |
| **Entregable Verificado** | Sí |
| **% Avance** | 100% |
| **Estado** | ✅ Completado |
| **Aprobado Por** | Todo el equipo |
| **Observaciones** | Queda pendiente revisión por Juan Diego para verificar si está completa |
