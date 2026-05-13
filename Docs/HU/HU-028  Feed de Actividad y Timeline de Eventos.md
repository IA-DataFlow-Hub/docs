# HU-028 — Feed de Actividad y Timeline de Eventos

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero visualizar un feed cronológico de todas las acciones realizadas dentro de los proyectos, datasets, chats y procesos IA,

para tener trazabilidad completa de actividades, auditoría visual y seguimiento en tiempo real del flujo de trabajo.

---

# Objetivo

Implementar un sistema de timeline/feed de actividad que permita:

- visualizar eventos cronológicos
- registrar acciones del sistema
- registrar acciones de usuarios
- registrar eventos IA
- mostrar transformaciones ETL
- mostrar actividad colaborativa
- mostrar estado de datasets
- centralizar auditoría visual

---

# Problema Actual

Actualmente existen:

- audit_logs
- conversaciones
- jobs IA
- datasets
- transformaciones

Pero NO existe:

- un feed visual unificado
- timeline de eventos
- eventos estructurados
- agrupación cronológica
- actividad colaborativa centralizada

---

# Solución Propuesta

Crear un sistema de eventos y timeline que permita visualizar:

```text
Archivo cargado
    ↓
Análisis IA ejecutado
    ↓
Transformación aplicada
    ↓
Datos corregidos
    ↓
Optimización sugerida
```

todo en tiempo real y relacionado al proyecto.

---

# Requerimientos Funcionales

---

## RF-01 — Feed cronológico

El sistema debe mostrar eventos ordenados por fecha descendente.

---

## RF-02 — Relación con proyecto

Cada evento debe pertenecer a:

- proyecto
- usuario
- fase BPM

---

## RF-03 — Eventos soportados

El sistema debe soportar eventos como:

- archivo cargado
- análisis IA
- transformación aplicada
- datos editados
- comentario agregado
- ETL ejecutado
- optimización sugerida
- error detectado
- validación completada
- exportación
- login
- reporte generado

---

## RF-04 — Relación con entidades

Un evento podrá relacionarse con:

- dataset
- conversación
- mensaje
- ETL
- job IA
- archivo
- tarea

---

## RF-05 — Tiempo relativo

El frontend debe mostrar:

```text
Hace 5m
Hace 2h
Hace 1d
```

---

## RF-06 — Etiquetas BPM

Cada evento debe mostrar la fase:

- DISEÑAR
- EJECUTAR
- SUPERVISAR
- OPTIMIZAR

---

## RF-07 — Severidad visual

Los eventos podrán tener prioridad:

- info
- success
- warning
- error
- critical

---

## RF-08 — Tiempo real

El feed debe actualizarse automáticamente usando:

- websockets
- Laravel Echo
- Redis
- Socket.IO

---

## RF-09 — Filtros

El usuario podrá filtrar por:

- usuario
- fase
- tipo evento
- fecha
- dataset
- conversación

---

## RF-10 — Agrupación inteligente

El sistema podrá agrupar eventos similares.

Ejemplo:

```text
3 archivos cargados
```

---

# Diseño Técnico

---

# Tabla: activity_feed

```sql
CREATE TABLE activity_feed (
    id_activity INT AUTO_INCREMENT PRIMARY KEY,

    id_project INT NOT NULL,

    id_user INT NULL,

    id_phase INT NULL,

    id_conversation INT NULL,

    id_message INT NULL,

    id_generated_table INT NULL,

    id_job INT NULL,

    id_execution INT NULL,

    id_file INT NULL,

    activity_type ENUM(
        'file_uploaded',
        'analysis_completed',
        'transformation_applied',
        'data_edited',
        'optimization_suggested',
        'etl_executed',
        'validation_completed',
        'comment_added',
        'dataset_generated',
        'error_detected',
        'export_generated',
        'user_login',
        'report_created'
    ) NOT NULL,

    activity_level ENUM(
        'info',
        'success',
        'warning',
        'error',
        'critical'
    ) DEFAULT 'info',

    title VARCHAR(255) NOT NULL,

    description TEXT,

    metadata JSON NULL,

    is_system_generated BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_activity_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_dataset
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_execution
        FOREIGN KEY (id_execution)
        REFERENCES etl_executions(id_execution)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_file
        FOREIGN KEY (id_file)
        REFERENCES files(id_file)
        ON DELETE SET NULL
);
```

---

# Índices Recomendados

```sql
CREATE INDEX idx_activity_project
    ON activity_feed(id_project);

CREATE INDEX idx_activity_user
    ON activity_feed(id_user);

CREATE INDEX idx_activity_type
    ON activity_feed(activity_type);

CREATE INDEX idx_activity_created
    ON activity_feed(created_at);

CREATE INDEX idx_activity_phase
    ON activity_feed(id_phase);
```

---

# Metadata JSON Ejemplo

```json
{
  "duplicates_detected": 15,
  "null_values": 3,
  "affected_column": "Precio",
  "rows_processed": 1250,
  "execution_time_ms": 3250
}
```

---

# Flujo Esperado

```text
Usuario sube archivo
    ↓
Sistema genera evento
    ↓
IA analiza dataset
    ↓
Sistema registra análisis
    ↓
Usuario aplica ETL
    ↓
Sistema registra transformación
```

---

# Casos de Uso

---

## Caso 1 — Archivo cargado

Sistema registra:

```text
Archivo cargado
ventas_2026.xlsx - 2.4 MB
```

---

## Caso 2 — Análisis IA

IA detecta:

- duplicados
- nulos
- fechas inconsistentes

y registra evento.

---

## Caso 3 — Optimización sugerida

Sistema detecta:

```text
Índice recomendado en columna Fecha
```

y lo agrega al feed.

---

## Caso 4 — Datos editados

Usuario corrige:

```text
3 valores en columna Precio
```

y queda registrado.

---

# Beneficios

- Auditoría visual
- Timeline centralizado
- Mejor trazabilidad
- Transparencia operativa
- Colaboración
- Debugging más fácil
- Historial completo del proyecto

---

# Arquitectura Recomendada

```text
Eventos Sistema
    ↓
Queue/Event Bus
    ↓
Activity Feed Service
    ↓
MySQL metadata
    ↓
Frontend realtime
```

---

# Posibles Mejoras Futuras

- Infinite scroll
- Feed inteligente con IA
- Resumen automático diario
- Búsqueda semántica
- Replay de eventos
- Métricas visuales
- Timeline gráfico
- Event sourcing
- Kafka/RabbitMQ
- Observabilidad distribuida
- Activity analytics
- Sistema de insights IA

---