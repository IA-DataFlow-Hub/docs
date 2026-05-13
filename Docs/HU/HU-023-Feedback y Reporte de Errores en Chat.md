# HU 023- Sistema de Feedback y Reporte de Chats

## Código
HU-CHAT-001

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero poder calificar respuestas de la IA y reportar errores o comportamientos incorrectos en conversaciones, mensajes o en la aplicación,

para mejorar la calidad de las respuestas, identificar fallos y mantener trazabilidad de incidencias.

---

# Objetivo

Implementar un sistema de feedback y reportes integrado al módulo de conversaciones y mensajes.

El sistema debe permitir:

- Calificar mensajes individuales con:
  - 👍 Bueno
  - 👎 Malo

- Reportar:
  - Un mensaje específico
  - Una conversación completa
  - Un problema general de la aplicación

---

# Requerimientos Funcionales

## RF-01 — Feedback de mensajes

El usuario podrá reaccionar a un mensaje con:

- like
- dislike

Solo se permitirá una reacción por usuario sobre el mismo mensaje.

---

## RF-02 — Reporte de mensaje

El usuario podrá reportar un mensaje específico indicando:

- motivo
- descripción opcional

Ejemplos:

- Respuesta incorrecta
- Información falsa
- Contenido ofensivo
- Error técnico
- Duplicación
- Otro

---

## RF-03 — Reporte de conversación

El usuario podrá reportar una conversación completa.

Debe permitir describir:

- problema general
- comportamiento extraño
- IA fuera de contexto
- lentitud
- errores de flujo

---

## RF-04 — Reporte general de la aplicación

El usuario podrá crear reportes generales no asociados a chats.

Ejemplos:

- Error visual
- Problemas de rendimiento
- Fallos de autenticación
- Problemas de carga
- Bugs del sistema

---

## RF-05 — Evidencia y trazabilidad

Todo reporte debe almacenar:

- usuario que reporta
- fecha
- tipo de reporte
- prioridad
- estado
- referencia asociada

---

## RF-06 — Gestión de estados

Los reportes tendrán estados:

- pending
- in_review
- resolved
- rejected

---

# Diseño Técnico

---

# Nueva Tabla: message_feedback

```sql
CREATE TABLE message_feedback (
    id_feedback INT AUTO_INCREMENT PRIMARY KEY,

    id_message INT NOT NULL,
    id_user INT NOT NULL,

    feedback_type ENUM('like','dislike') NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_feedback_unique
        UNIQUE(id_message, id_user),

    CONSTRAINT fk_feedback_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE CASCADE,

    CONSTRAINT fk_feedback_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);
```

---

# Nueva Tabla: reports

```sql
CREATE TABLE reports (
    id_report INT AUTO_INCREMENT PRIMARY KEY,

    id_user INT NOT NULL,

    report_type ENUM(
        'message',
        'conversation',
        'application'
    ) NOT NULL,

    id_message INT NULL,
    id_conversation INT NULL,
    id_project INT NULL,

    category ENUM(
        'incorrect_response',
        'offensive_content',
        'technical_error',
        'performance_issue',
        'security_issue',
        'ui_bug',
        'other'
    ) DEFAULT 'other',

    priority ENUM(
        'low',
        'medium',
        'high',
        'critical'
    ) DEFAULT 'medium',

    description TEXT,

    status ENUM(
        'pending',
        'in_review',
        'resolved',
        'rejected'
    ) DEFAULT 'pending',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,

    CONSTRAINT fk_reports_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_reports_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_reports_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_reports_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE SET NULL
);
```

---

# Reglas de Negocio

## Feedback

- Un usuario solo puede reaccionar una vez por mensaje.
- Puede cambiar de like a dislike.
- No se permiten múltiples reacciones simultáneas.

---

## Reportes

- Un reporte debe tener al menos:
  - mensaje
  - conversación
  - o tipo aplicación

- Los administradores podrán:
  - ver reportes
  - cambiar estado
  - resolver incidencias

---

# Casos de Uso

## Caso 1 — Feedback positivo

Usuario:
- presiona 👍
- sistema registra feedback_type = like

---

## Caso 2 — Reporte de mensaje IA

Usuario:
- selecciona "Reportar"
- escoge:
  - respuesta incorrecta
- escribe descripción
- sistema crea reporte tipo message

---

## Caso 3 — Reporte general del sistema

Usuario:
- abre módulo de soporte
- reporta lentitud en carga
- sistema crea reporte tipo application

---

# Beneficios

- Mejora continua de IA
- Métricas de calidad
- Detección temprana de errores
- Moderación y auditoría
- Trazabilidad de incidencias
- Dataset para entrenamiento futuro

---

# Posibles Mejoras Futuras

- Adjuntar imágenes al reporte
- Logs automáticos del frontend
- Captura automática de stacktrace
- Moderación automática con IA
- Dashboard analítico
- Métricas de satisfacción
- Sistema de tickets
- Integración con Jira/GitHub Issues

---