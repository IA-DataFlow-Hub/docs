**Fecha:** 10 de marzo de 2026

**Responsables:** Juan Diego Mejía / David Ospina

**Estado:** Diseño de Estructura y Lógica de Negocio

## 1. Arquitectura de N-Capas (Propuesta)

Para garantizar la escalabilidad, se propone una arquitectura desacoplada donde la IA sea un servicio independiente:

- **Capa de Presentación:** React.js (Dashboards interactivos).
    
- **Capa de Aplicación (API):** Node.js/Fastify (Orquestación de procesos).
    
- **Capa de Inteligencia:** Motor de IA (Gemini 1.5 Flash) vía n8n/LangChain.
    
- **Capa de Datos:** PostgreSQL / MySQL (Persistencia de metadatos y usuarios).
    

---

## 2. Modelo Entidad-Relación (DER)

El sistema debe soportar **Multi-tenancy** (múltiples empresas separadas). Las tablas principales son:

- **Users:** Perfiles, roles y credenciales (vinculada a HU 04).
    
- **Projects:** Contenedor de datos por empresa.
    
- **Data_Sources:** Registro de archivos cargados (Nombre, tipo, tamaño).
    
- **Data_Versions:** Historial de limpiezas aplicadas (permite volver atrás).
    
- **AI_Audit:** Log de sugerencias aceptadas/rechazadas por el usuario.
    

---

## 3. Flujo de Comunicación (Diagrama de Secuencia)

El proceso crítico de limpieza sigue este orden técnico:

1. **Frontend:** Envía archivo vía `POST /upload`.
    
2. **Backend:** Valida sesión, genera ID de proceso y responde `202 Accepted` (no bloquea al usuario).
    
3. **Worker (IA):** Procesa el archivo en segundo plano y extrae metadatos.
    
4. **WebSocket:** Notifica al Frontend: "Análisis completo, revise sugerencias".
    
5. **User:** Aprueba cambios y el sistema guarda la nueva versión en la DB.
    

---

## 4. Estándar de Intercambio (JSON Metadata)

Para que el Frontend entienda qué encontró la IA, se define el siguiente esquema mínimo de respuesta:

JSON

```
{
  "file_id": "uuid-12345",
  "total_records": 100000,
  "analysis": {
    "columns": [
      {"name": "Email", "type": "String", "null_pct": 5.2, "errors": "Formato inválido"},
      {"name": "Total", "type": "Float", "null_pct": 0.0, "errors": "Valores negativos detectados"}
    ],
    "ai_suggestion": "Se recomienda normalizar la columna Email y eliminar duplicados en ID_Cliente."
  }
}
```

---

## 5. Conclusión / Recomendación

Se recomienda el uso de **Diagramas C4** para la arquitectura general y **UML 2.5** para la secuencia. David Ospina (Arquitectura C#) se encargará de validar que el DER sea eficiente para consultas complejas, mientras Juan Diego asegura que la lógica de la IA se integre sin cuellos de botella mediante el estándar JSON definido.