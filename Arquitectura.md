### 📂 Estructura del Monorepositorio (Vista de Archivos)

Plaintext

```
IA-DataFlow-Hub/
├── apps/
│   ├── client/                 # Frontend (React + Vite)
│   │   ├── Dockerfile
│   │   └── ...
│   └── api/                    # Backend (NestJS)
│       ├── Dockerfile
│       └── ...
├── packages/
│   ├── database/               # CAPA DE MIGRACIONES (Prisma/TypeORM)
│   │   ├── schema.prisma       # Definición de tablas (estilo Laravel)
│   │   └── migrations/         # Historial de cambios en la DB
│   └── shared-types/           # Interfaces TS comunes
├── ai-services/
│   ├── fine-tuning/            # Datasets y Notebooks
│   └── prompts/                # Biblioteca de prompts
├── infra/
│   ├── nginx/
│   │   └── default.conf        # Proxy Inverso
│   └── n8n/                    # Configuración de flujos
├── .env                        # Variables globales (GitIgnored)
├── docker-compose.yml          # Orquestador de servicios
├── turbo.json                  # Configuración de Turborepo
└── package.json                # Root package (Workspaces)
```

### 🏗️ Arquitectura de Servicios (Docker Compose)

En tu archivo `docker-compose.yml`, así es como se conectarán todas las piezas:

YAML

```
services:
  # El "Policía" que redirige el tráfico
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./infra/nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - client
      - api

  # Interfaz de Usuario
  client:
    build: ./apps/client
    environment:
      - VITE_API_URL=http://api.iadataflow.com/api

  # Lógica de Negocio e IA
  api:
    build: ./apps/api
    environment:
      - DATABASE_URL=mysql://user:pass@db:3306/iadataflow
      - AI_HOST=http://host.docker.internal:1234 # LM Studio
    depends_on:
      - db

  # Automatización de Flujos (n8n)
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=mysqldb
      - DB_MYSQLDB_HOST=db

  # Base de Datos con persistencia
  db:
    image: mysql:8.0
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

---

### 🔄 Migraciones: El "Laravel Way" en NestJS

Para manejar las migraciones como lo haces en Laravel (`php artisan migrate`), te recomiendo usar **Prisma**.

1. **Definición:** En `packages/database/schema.prisma` defines tus modelos.
    
2. **Ejecución:** En lugar de `make:migration`, usas:
    
    Bash
    
    ```
    npx prisma migrate dev --name init_database
    ```
    
3. **Sincronización:** Esto crea las tablas en MySQL y, lo más importante, genera un cliente de TypeScript que tu API de NestJS usará para tener autocompletado total.
    

---

### 🛡️ Manejo de Variables de Entorno (`.env`)

Para que el proyecto sea seguro y portátil:

- **En la Raíz:** Tienes un `.env` con las claves maestras (DB_PASSWORD, API_KEYS).
    
- **En Apps:** Turborepo puede inyectar estas variables en cada microservicio.
    
- **Seguridad:** El archivo `.env` nunca se sube a GitHub. En su lugar, dejas un `.env.example` para que tus compañeros (Sebastián, Andrés) sepan qué valores deben llenar.
    

---

### 💡 Resumen Técnico para Obsidian

- **Turborepo** coordina que cuando lances el proyecto, el **Backend** y el **Frontend** arranquen juntos y compartan las **Shared-Types**.
    
- **Nginx** permite que accedas a través de `iadataflow.com` (Frontend) y `api.iadataflow.com` (Backend).
    
- **n8n** se integra para crear flujos de datos automáticos (ej: "Cuando llegue un email, pásalo por IA-DataFlow").
    
- **Docker** encapsula todo para que tu RTX 5060 Ti solo se preocupe por procesar la IA, mientras el resto del sistema corre aislado y estable.


## 🏛️ Estructura de Capas en `apps/api` (Backend)

Dentro de tu carpeta `apps/api`, la estructura de archivos debe reflejar la independencia de la lógica:

Plaintext

```
apps/api/src/
├── domain/                # CAPA 1: EL CORAZÓN (Entidades y Reglas de Negocio)
│   ├── entities/          # Ej: DataFile.entity.ts, User.entity.ts
│   └── repositories/      # Interfaces (Contratos). Ej: IDataRepository.ts
│
├── application/           # CAPA 2: CASOS DE USO (Orquestación)
│   ├── use-cases/         # Ej: CleanDataFile.use-case.ts, ProcessIAAnalysis.ts
│   └── dto/               # Data Transfer Objects
│
├── infrastructure/        # CAPA 3: DETALLES (Implementaciones externas)
│   ├── persistence/       # Implementación de Prisma/TypeORM
│   ├── ai-services/       # Implementación de la conexión a LM Studio
│   └── repositories/      # Código real que habla con la DB
│
└── presentation/          # CAPA 4: ENTRADA (Controladores)
    └── controllers/       # Controladores de NestJS (REST / WebSockets)
```

---

## 🔄 El Flujo de Dependencias

La regla de oro es: **Las dependencias solo pueden ir hacia adentro.**

1. **Domain:** No sabe que existe NestJS ni la base de datos. Solo define qué es un "Dato" y qué interfaces necesita para guardarse.
    
2. **Application:** Llama al Dominio. Aquí es donde vive la lógica de tu proyecto: _"Primero valida el archivo, luego pide a la IA que lo limpie y finalmente guárdalo"_.
    
3. **Infrastructure:** Aquí es donde instalas los paquetes de terceros. Si mañana decides cambiar MySQL por PostgreSQL, solo tocas esta capa; el resto del código ni se entera.
    

---

## 🛠️ Implementación en el Monorepo (Integración con `/packages`)

Para que la arquitectura sea realmente "limpia" y aproveches **Turborepo**, moveremos los elementos comunes:

### 1. `packages/database` (Infraestructura Compartida)

Aquí vive tu esquema de **Prisma**. El backend (`apps/api`) lo importa en su capa de infraestructura.

### 2. `packages/shared-types` (Contratos de Dominio)

Aquí defines las interfaces de TypeScript que tanto el **Frontend** como el **Backend** van a usar. Esto asegura que si el Backend dice que un archivo tiene un `status: 'processed'`, el Frontend sepa exactamente qué esperar.

---

## 📝 Ejemplo Práctico: Caso de Uso "Limpiar Datos"

Así se vería la separación de responsabilidades:

- **Dominio:** Define la interfaz `IAIService` con un método `clean(data: any): Promise<any>`.
    
- **Infraestructura:** Implementa `LMStudioService` que cumple con la interfaz de arriba y usa `axios` para llamar a tu puerto local.
    
- **Caso de Uso (Aplicación):** Recibe el archivo, llama a `IAIService.clean()` y le ordena al repositorio que lo guarde. **No sabe que estás usando LM Studio**, solo sabe que algo limpia los datos.
    

---

## ✅ Ventajas para IA-DataFlow

1. **Testabilidad:** Puedes probar tu lógica de limpieza de datos sin encender la IA ni la base de datos (usando Mocks).
    
2. **Escalabilidad:** Si Sebastián o Andrés necesitan agregar un nuevo módulo, saben exactamente dónde poner el código sin romper el de los demás.
    
3. **Independencia de IA:** Puedes tener una implementación para **LM Studio** y otra para **Gemini**. Cambiar entre ellas es solo cambiar una línea en el archivo de configuración de la capa de infraestructura.
    

> [!TIP] En NestJS Usa la **Inyección de Dependencias** de NestJS para pasar las implementaciones de infraestructura a los casos de uso. Así mantendrás el desacoplamiento total.


### 🏛️ 1. Arquitectura del Backend (`apps/api`)

En NestJS, la arquitectura limpia se organiza para que el "Framework" no contamine tu lógica de negocio.

Plaintext

```
apps/api/src/
├── domain/                # CAPA 1: EL CORAZÓN (Reglas de Negocio Puras)
│   ├── entities/          # Clases base (ej. DataFile.ts, Report.ts)
│   ├── repositories/      # Interfaces/Contratos (ej. IDataRepository.ts)
│   └── services/          # Lógica que no pertenece a una sola entidad
│
├── application/           # CAPA 2: CASOS DE USO (Orquestación)
│   ├── use-cases/         # Ej: CleanExcelData.ts, GenerateAIReport.ts
│   └── dto/               # Objetos de transferencia de datos
│
├── infrastructure/        # CAPA 3: DETALLES (Implementaciones externas)
│   ├── persistence/       # Implementación de Prisma (Repositories reales)
│   ├── ai-engine/         # Adaptador para conectar con LM Studio/Gemini
│   └── shared/            # Loggers, Helpers de fechas, etc.
│
└── presentation/          # CAPA 4: ENTRADA (Controladores)
    ├── controllers/       # HTTP / Rest (NestJS Controllers)
    └── resolvers/         # GraphQL o WebSockets (si aplicara)
```

---

### ⚛️ 2. Arquitectura del Frontend (`apps/client`)

En React, la arquitectura limpia sirve para que puedas cambiar de librería de UI (ej. de Tailwind a Material UI o de React a Next.js) sin reescribir la lógica de procesamiento.

Plaintext

```
apps/client/src/
├── core/                  # CAPA DE DOMINIO Y APLICACIÓN
│   ├── entities/          # Modelos de datos (Interfaces de TypeScript)
│   ├── use-cases/         # Lógica de validación de formularios o UI
│   └── repositories/      # Definición de cómo se piden los datos (Interfaces)
│
├── data/                  # CAPA DE INFRAESTRUCTURA
│   ├── sources/           # Llamadas reales a la API (Axios/Fetch)
│   └── mappers/           # Transforman datos de la API al formato de la UI
│
└── presentation/          # CAPA DE VISTA
    ├── components/        # Componentes reutilizables (Botones, Tablas)
    ├── views/             # Páginas completas (Dashboard, Login)
    └── state/             # Gestión de estado (Zustand/Redux/Context)
```

---

### 🔗 3. Integración con `/packages` (Compartidos)

Para que el sistema sea robusto, usaremos los paquetes centralizados que definimos antes:

- **`packages/shared-types`**: Aquí defines los **Contratos de Dominio**. Por ejemplo: la interfaz `IDataOutput`. Tanto el Backend como el Frontend la importan para que no haya errores de comunicación.
    
- **`packages/database`**: Contiene el esquema de **Prisma**. El Backend lo usa en su capa de `infrastructure/persistence` para realizar las migraciones (estilo Laravel).
    

---

### 🔄 Ejemplo de Flujo: "Procesar Archivo"

1. **Frontend (`apps/client`)**: El usuario sube un Excel. La capa de `data` envía el archivo a la API.
    
2. **API Presentation (`apps/api`)**: El controlador recibe el archivo y lo pasa al **Caso de Uso** `ProcessFileUseCase`.
    
3. **API Application**: El Caso de Uso le pide a la **Infraestructura de IA** que limpie el dato.
    
4. **API Infrastructure**: Se comunica con tu **RTX 5060 Ti** a través de **LM Studio** para procesar.
    
5. **API Infrastructure (Persistence)**: Guarda el resultado usando **Prisma** (ejecutando la migración correspondiente).
    
6. **Respuesta**: Todo vuelve al Frontend de forma estructurada.
    

---

### ✅ Beneficios para tu equipo:

- **Para Juan Diego (Infraestructura)**: Puedes cambiar el motor de IA en la capa de `infrastructure` sin tocar el resto del código.
    
- **Para Sebastián (Backend)**: Las migraciones en `packages/database` mantienen la base de datos sincronizada para todos.
    
- **Para el equipo de Frontend**: Saben exactamente qué datos esperar gracias a los `shared-types`.
    

> [!TIP] Dado que quieres algo similar a Laravel, **Prisma** es tu mejor aliado. Ejecuta `npx prisma migrate dev` dentro de `packages/database` y tendrás el control total del historial de tu base de datos.
> 