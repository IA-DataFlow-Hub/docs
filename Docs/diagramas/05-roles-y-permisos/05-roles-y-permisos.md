# Diagrama 5 — Roles y permisos

**Qué muestra:** Cómo se resuelve el acceso de un usuario a un recurso según su rol.`iadataflow_net`.

**Última actualización:** 2026-05-13

```mermaid
graph TD
    %% Definición de estilos
    classDef global fill:#f9f2f4,stroke:#d9534f,stroke-width:2px;
    classDef team fill:#fcf8e3,stroke:#f0ad4e,stroke-width:2px;
    classDef project fill:#d9edf7,stroke:#5bc0de,stroke-width:2px;
    classDef role fill:#e2f0d9,stroke:#5cb85c,stroke-width:2px;
    classDef access fill:#dff0d8,stroke:#3c763d,stroke-width:2px;
    classDef deny fill:#f2dede,stroke:#a94442,stroke-width:2px;

    subgraph "1. Tipos de Roles y Permisos"
        Admin[**Administrador**<br>Permisos: Control Total <br>Crear, Leer, Editar, Borrar]:::role
        Sup[**Supervisor**<br>Permisos: Gestión parcial<br>Leer, Editar, Aprobar, Asignar]:::role
        Usr[**Usuario**<br>Permisos: Operación básica<br>Leer, Ejecutar, Crear propios]:::role
    end

    subgraph "2. Jerarquía y Herencia (Datos)"
        Global[**Global**<br>role_templates]:::global
        Equipo[**Equipo**<br>team_roles]:::team
        Proyecto[**Proyecto**<br>user_project_roles]:::project

        Global -->|Crea plantillas base| Equipo
        Equipo -->|Hereda o sobrescribe roles| Proyecto
        
        %% Relación ilustrativa de que un rol puede aplicarse en cualquier nivel
        Admin -.-> Global
        Sup -.-> Equipo
        Usr -.-> Proyecto
    end

    subgraph "3. Orden de Resolución de Permisos (Flujo)"
        Req([Usuario solicita acceso a un recurso])
        
        EvalP{1. Nivel Proyecto<br>¿Rol específico aquí?}:::project
        EvalT{2. Nivel Equipo<br>¿Rol heredado de equipo?}:::team
        EvalG{3. Nivel Global<br>¿Rol por defecto?}:::global
        
        Grant([Acceso Concedido<br>con permisos del Rol encontrado]):::access
        Deny([Acceso Denegado<br>Sin rol o permisos insuficientes]):::deny

        Req --> EvalP
        EvalP -- Sí --> Grant
        EvalP -- No --> EvalT
        
        EvalT -- Sí --> Grant
        EvalT -- No --> EvalG
        
        EvalG -- Sí --> Grant
        EvalG -- No --> Deny
    end

    %% Conexiones entre la estructura de datos y el flujo de evaluación
    Proyecto -.->|Consulta| EvalP
    Equipo -.->|Consulta| EvalT
    Global -.->|Consulta| EvalG
    ```