# IA-DataFlow-Hub — Arquitectura del Proyecto

## Indice

1. [Vision General](#1-vision-general)
2. [Estructura del Monorepo](#2-estructura-del-monorepo)
3. [Stack Tecnologico](#3-stack-tecnologico)
4. [Servicios Docker](#4-servicios-docker)
5. [Frontend — apps/client](#5-frontend--appsclient)
6. [Backend — apps/api](#6-backend--appsapi)
7. [Base de Datos — packages/database](#7-base-de-datos--packagesdatabase)
8. [Tipos Compartidos — packages/shared-types](#8-tipos-compartidos--packagesshared-types)
9. [Automatizacion — n8n](#9-automatizacion--n8n)
10. [IA Local — ai-services](#10-ia-local--ai-services)
11. [Infraestructura — infra/nginx](#11-infraestructura--infranginx)
12. [Variables de Entorno](#12-variables-de-entorno)
13. [Flujo de Desarrollo](#13-flujo-de-desarrollo)
14. [Flujo de Produccion](#14-flujo-de-produccion)

---

## 1. Vision General

**IA-DataFlow-Hub** es una plataforma de gestion y automatizacion de flujos de datos con integracion de inteligencia artificial. Esta construida como un **monorepo** gestionado con **Turborepo** y orquestada con **Docker Compose**.

```
Usuario
  │
  ├── http://localhost:5173  →  Frontend React (UI)
  ├── http://localhost:3000  →  API NestJS (REST)
  ├── http://localhost:5678  →  n8n (Automatizacion)
  ├── http://localhost:8080  →  phpMyAdmin (Admin BD)
  └── localhost:3307         →  MySQL (acceso externo)
```

Todos los servicios corren dentro de una red Docker interna (`iadataflow_net`). El frontend y la API son **imagenes propias construidas** desde los Dockerfiles del proyecto. Los demas servicios usan imagenes oficiales.

---

## 2. Estructura del Monorepo

```
IA-DataFlow-Hub/
│
├── apps/                          # Aplicaciones desplegables
│   ├── client/                    # Frontend — React + Vite
│   │   ├── Dockerfile             # Imagen propia: build React → nginx
│   │   ├── nginx.conf             # Configuracion nginx interna del contenedor
│   │   ├── vite.config.ts         # Bundler y servidor de desarrollo
│   │   ├── postcss.config.mjs     # Procesamiento CSS (Tailwind 4)
│   │   ├── index.html             # Entry point HTML
│   │   └── src/                   # Codigo fuente React
│   │       ├── main.tsx           # Punto de entrada
│   │       ├── app/
│   │       │   ├── App.tsx        # Componente raiz + Router
│   │       │   ├── routes.tsx     # Definicion de rutas
│   │       │   ├── components/    # Componentes de pagina
│   │       │   └── assets/        # Imagenes y recursos estaticos
│   │       └── styles/            # CSS global, temas, fuentes
│   │
│   └── api/                       # Backend — NestJS
│       ├── Dockerfile             # Imagen propia: build TS → node runtime
│       ├── nest-cli.json          # Configuracion del CLI de NestJS
│       ├── tsconfig.json          # TypeScript base
│       ├── tsconfig.build.json    # TypeScript para produccion
│       └── src/                   # Codigo fuente NestJS
│           ├── main.ts            # Bootstrap de la app (puerto 3000)
│           ├── app.module.ts      # Modulo raiz
│           ├── app.controller.ts  # Controlador principal
│           └── app.service.ts     # Servicio principal
│
├── packages/                      # Librerias compartidas entre apps
│   ├── database/                  # Capa de base de datos
│   │   ├── schema.prisma          # Definicion de modelos (Prisma ORM)
│   │   └── migrations/            # Historial de migraciones SQL
│   └── shared-types/              # Interfaces TypeScript comunes
│       └── index.ts               # ApiResponse, PaginatedResponse, UserBase
│
├── ai-services/                   # Servicios de inteligencia artificial
│   ├── fine-tuning/               # Datasets y notebooks de entrenamiento
│   └── prompts/                   # Biblioteca de prompts reutilizables
│
├── infra/                         # Configuracion de infraestructura
│   ├── nginx/
│   │   └── default.conf           # Proxy inverso (para produccion con dominios)
│   └── n8n/
│       └── data/                  # Datos persistentes de n8n (flujos, credenciales)
│
├── docs/                          # Documentacion del proyecto
│   └── ARQUITECTURA.md            # Este archivo
│
├── .env                           # Variables de entorno (NO commitear)
├── .env.example                   # Plantilla de variables
├── .dockerignore                  # Exclusiones del contexto de build Docker
├── docker-compose.yml             # Orquestacion de todos los servicios
├── turbo.json                     # Pipeline de tareas del monorepo
└── package.json                   # Workspace root (npm workspaces + turbo)
```

---

## 3. Stack Tecnologico

| Capa | Tecnologia | Version | Proposito |
|------|-----------|---------|-----------|
| Frontend | React | 18.x | UI reactiva |
| Frontend | Vite | 6.x | Bundler y dev server |
| Frontend | Tailwind CSS | 4.x | Estilos utilitarios |
| Frontend | shadcn/ui + Radix | latest | Componentes accesibles |
| Frontend | React Router | 7.x | Navegacion SPA |
| Frontend | Recharts | 2.x | Graficas y visualizaciones |
| Frontend | React Hook Form | 7.x | Formularios |
| Backend | NestJS | 11.x | Framework API REST |
| Backend | TypeScript | 5.x | Tipado estatico |
| Backend | Node.js | 20 | Runtime |
| Base de datos | MySQL | 8.0 | Persistencia principal |
| ORM | Prisma | — | Migraciones y queries |
| Automatizacion | n8n | latest | Flujos de trabajo sin codigo |
| Admin BD | phpMyAdmin | latest | Interfaz web para MySQL |
| Proxy | nginx | alpine | Servir frontend + proxy inverso |
| Monorepo | Turborepo | 2.x | Orquestacion de builds |
| Contenedores | Docker + Compose | — | Empaquetado y despliegue |
| IA Local | LM Studio | — | Modelo de lenguaje local |

---

## 4. Servicios Docker

El archivo `docker-compose.yml` define 5 servicios en la red `iadataflow_net`.

```
┌─────────────────────────────────────────────────────────────┐
│                     RED: iadataflow_net                     │
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │  client  │    │   api    │    │   n8n    │             │
│  │ :5173→80 │    │  :3000   │    │  :5678   │             │
│  └──────────┘    └────┬─────┘    └──────────┘             │
│                       │                                     │
│              ┌────────▼────────┐                           │
│              │       db        │                           │
│              │  mysql:8.0      │                           │
│              │  :3307→3306     │                           │
│              └────────┬────────┘                           │
│                       │                                     │
│              ┌────────▼────────┐                           │
│              │   phpmyadmin    │                           │
│              │    :8080→80     │                           │
│              └─────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

### client

| Campo | Valor |
|-------|-------|
| Imagen | `iadataflow/client:latest` (build propio) |
| Dockerfile | `apps/client/Dockerfile` |
| Puerto | `5173:80` |
| Healthcheck | `curl -fs http://localhost:80` |
| Dependencias | ninguna |

Construye el frontend React con Vite y lo sirve con nginx en el puerto 80 del contenedor. El healthcheck usa `curl` porque el `wget` de BusyBox en alpine no soporta `--spider` correctamente.

### api

| Campo | Valor |
|-------|-------|
| Imagen | `iadataflow/api:latest` (build propio) |
| Dockerfile | `apps/api/Dockerfile` |
| Puerto | `3000:3000` |
| Healthcheck | `wget -q --spider http://localhost:3000` |
| Dependencias | `db` con `condition: service_healthy` |
| Usuario | `nestjs` (no-root, uid 1001) |

Espera a que MySQL este healthy antes de iniciar. Se conecta a la base de datos via la red Docker interna usando `db:3306`. Tiene acceso al host Windows via `host.docker.internal` para conectarse a LM Studio.

### db

| Campo | Valor |
|-------|-------|
| Imagen | `mysql:8.0` |
| Puerto | `3307:3306` (3306 reservado para MySQL local) |
| Volumen | `db_data:/var/lib/mysql` |
| Healthcheck | `mysqladmin ping` con `start_period: 30s` |

El puerto externo es `3307` porque el puerto `3306` ya esta ocupado por una instalacion local de MySQL en el host. Internamente, todos los servicios Docker se conectan en `db:3306`.

### phpmyadmin

| Campo | Valor |
|-------|-------|
| Imagen | `phpmyadmin:latest` |
| Puerto | `8080:80` |
| Dependencias | `db` con `condition: service_healthy` |

Interfaz web para administrar la base de datos MySQL. Accede en http://localhost:8080 con usuario `root` y la contrasena definida en `DB_PASSWORD`.

### n8n

| Campo | Valor |
|-------|-------|
| Imagen | `n8nio/n8n:latest` |
| Puerto | `5678:5678` |
| Volumen | `./infra/n8n/data:/home/node/.n8n` |
| Persistencia | SQLite via bind mount en `infra/n8n/data/` |

Motor de automatizacion de flujos. Los flujos y credenciales se persisten en la carpeta local `infra/n8n/data/` para no perder configuracion entre reinicios.

---

## 5. Frontend — apps/client

### Arquitectura interna

```
src/
├── main.tsx              # ReactDOM.createRoot → monta <App />
├── app/
│   ├── App.tsx           # Proveedor de contextos + <RouterProvider>
│   ├── routes.tsx        # Definicion de rutas con React Router 7
│   ├── components/       # Paginas y componentes de dominio
│   │   ├── LandingPage   # Pagina de inicio
│   │   ├── Login / Register
│   │   ├── Dashboard     # Panel principal
│   │   ├── ProjectManager
│   │   ├── Teams
│   │   ├── UserProfile
│   │   └── ui/           # Componentes base (shadcn/ui)
│   └── assets/           # Imagenes
└── styles/
    ├── index.css         # Estilos globales
    ├── tailwind.css      # Directivas Tailwind
    ├── theme.css         # Variables CSS del tema
    └── fonts.css         # Fuentes
```

### Contextos globales

| Contexto | Archivo | Proposito |
|----------|---------|-----------|
| `ThemeContext` | ThemeContext.tsx | Tema claro/oscuro |
| `ProjectContext` | ProjectContext.tsx | Proyecto activo |
| `NotificationContext` | NotificationContext.tsx | Notificaciones globales |

### Build Docker (Dockerfile)

El Dockerfile del cliente usa **2 stages**:

```
Stage 1 (builder) — node:20-alpine
  ├── npm ci                    # Instala dependencias exactas (package-lock.json)
  ├── COPY vite.config.ts
  ├── COPY postcss.config.mjs   # Necesario para Tailwind 4
  ├── COPY index.html
  ├── COPY src/
  └── npm run build             # Genera dist/ con archivos estaticos

Stage 2 (runtime) — nginx:alpine
  ├── COPY dist/ → /usr/share/nginx/html
  ├── COPY nginx.conf           # SPA routing: todo apunta a index.html
  └── HEALTHCHECK curl -fs http://localhost:80
```

El `nginx.conf` del cliente configura:
- Fallback a `index.html` para rutas SPA
- Cache de 1 año para assets estaticos (JS, CSS, imagenes)

---

## 6. Backend — apps/api

### Arquitectura interna

```
src/
├── main.ts            # Bootstrap: NestFactory.create(AppModule) → puerto 3000
├── app.module.ts      # Modulo raiz — importa todos los modulos de features
├── app.controller.ts  # Controlador base (ruta GET /)
└── app.service.ts     # Servicio base
```

El patron de NestJS organiza el codigo en **modulos**, cada uno con su controlador, servicio y entidades.

### Variables de entorno que consume la API

| Variable | Descripcion |
|----------|-------------|
| `DATABASE_URL` | Conexion MySQL: `mysql://root:<pass>@db:3306/<db>` |
| `JWT_SECRET` | Clave para firmar tokens JWT |
| `NODE_ENV` | `production` en Docker, `development` en local |
| `AI_ENGINE_URL` | URL del modelo local: `http://host.docker.internal:1234/v1` |

### Build Docker (Dockerfile)

El Dockerfile de la API usa **3 stages** para optimizar el tamano de la imagen final:

```
Stage 1 (deps) — node:20-alpine
  └── npm ci --omit=dev         # Solo dependencias de produccion

Stage 2 (builder) — node:20-alpine
  ├── npm ci                    # Todas las dependencias (incluyendo dev)
  ├── COPY tsconfig*.json
  ├── COPY nest-cli.json
  ├── COPY src/
  └── npm run build             # Compila TypeScript → dist/

Stage 3 (runtime) — node:20-alpine
  ├── RUN adduser nestjs        # Usuario no-root (uid 1001)
  ├── USER nestjs
  ├── COPY --from=deps node_modules/    # Solo prod deps
  ├── COPY --from=builder dist/         # Codigo compilado
  └── HEALTHCHECK wget http://localhost:3000
```

La imagen final no contiene TypeScript, el compilador ni herramientas de desarrollo.

---

## 7. Base de Datos — packages/database

La capa de base de datos se gestiona con **Prisma ORM** desde el paquete compartido `packages/database`.

### schema.prisma

Define la fuente de verdad de la base de datos:

```prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}
```

Los modelos se definen aqui y se comparten con la API mediante el cliente generado de Prisma.

### Migraciones

El directorio `packages/database/migrations/` almacena el historial de cambios estructurales. Cada migracion es un archivo SQL generado por Prisma que representa una version del schema.

**Flujo de trabajo:**
```bash
# Crear una nueva migracion
npx prisma migrate dev --name nombre_del_cambio

# Aplicar migraciones en produccion
npx prisma migrate deploy

# Ver el estado de la BD
npx prisma studio
```

---

## 8. Tipos Compartidos — packages/shared-types

El paquete `packages/shared-types` expone interfaces TypeScript reutilizables en la API y el frontend, garantizando consistencia en los contratos de datos.

```typescript
// Respuesta estandar de la API
interface ApiResponse<T> {
  data: T;
  message: string;
  success: boolean;
}

// Respuesta paginada
interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
}
```

---

## 9. Automatizacion — n8n

**n8n** es el motor de automatizacion de flujos de trabajo. Permite conectar la API, la base de datos, servicios externos y el modelo de IA sin escribir codigo.

- **URL**: http://localhost:5678
- **Persistencia**: `infra/n8n/data/` (SQLite + credenciales + flujos)
- **Casos de uso tipicos**:
  - Disparar flujos al recibir datos nuevos
  - Conectar la API con servicios externos (Slack, email, webhooks)
  - Procesar respuestas del modelo de IA
  - Programar tareas periodicas

Los flujos se guardan en la carpeta local y sobreviven a reinicios del contenedor.

---

## 10. IA Local — ai-services

El directorio `ai-services/` contiene los recursos relacionados con inteligencia artificial:

```
ai-services/
├── fine-tuning/    # Datasets y notebooks para ajuste fino de modelos
└── prompts/        # Biblioteca de prompts reutilizables y testeados
```

La API se conecta al modelo de lenguaje local a traves de **LM Studio**, que expone una API compatible con OpenAI en:

```
http://host.docker.internal:1234/v1
```

La URL `host.docker.internal` es la direccion especial que Docker usa para acceder al sistema Windows anfitrion desde dentro de un contenedor.

---

## 11. Infraestructura — infra/nginx

El archivo `infra/nginx/default.conf` define un proxy inverso para produccion con dominios reales:

| Dominio | Destino interno |
|---------|----------------|
| `iadataflow.com` | `iadataflow_client:80` |
| `api.iadataflow.com` | `iadataflow_api:3000` |
| `n8n.iadataflow.com` | `iadataflow_n8n:5678` |

Incluye soporte para **WebSockets** en el bloque de la API (util para notificaciones en tiempo real del modelo de IA).

Este proxy no esta activo en el entorno de desarrollo local — cada servicio es directamente accesible por su puerto.

---

## 12. Variables de Entorno

El archivo `.env` en la raiz define todas las variables del proyecto. Nunca se commitea al repositorio (esta en `.gitignore`). Usa `.env.example` como plantilla.

```env
# Base de datos
DB_PASSWORD=mi_super_clave_123   # Contrasena de MySQL
DB_NAME=ia_dataflow              # Nombre de la base de datos

# Seguridad
JWT_SECRET=clave_larga_y_segura  # Clave para JWT de la API

# IA Local (LM Studio corriendo en el host)
AI_ENGINE_URL=http://host.docker.internal:1234/v1

# n8n
N8N_HOST=localhost               # Dominio de n8n (localhost en dev)
N8N_PROTOCOL=http                # http en local, https en produccion
TIMEZONE=America/Bogota          # Zona horaria para tareas programadas
```

---

## 13. Flujo de Desarrollo

### Desarrollo local (sin Docker)

```bash
# Instalar dependencias de todos los workspaces
npm install

# Levantar todos los servicios en paralelo (Turbo)
npm run dev
# → Ejecuta: apps/api (NestJS watch) + apps/client (Vite HMR)

# Compilar todo
npm run build
# → Compila con cache inteligente (solo lo que cambio)
```

Turbo gestiona el orden de ejecucion y mantiene cache entre builds. Si no cambio ninguna dependencia, el siguiente `npm run build` usa la cache y tarda segundos.

### Desarrollo con Docker

```bash
# Primera vez (descarga imagenes + construye imagenes propias)
docker-compose up --build

# Siguiente vez (sin rebuild)
docker-compose up

# Solo algunos servicios
docker-compose up client api

# Ver logs en tiempo real
docker-compose logs -f api

# Reconstruir una imagen especifica
docker-compose build api
docker-compose up -d --force-recreate api
```

---

## 14. Flujo de Produccion

Para produccion se recomienda:

1. **Pinear versiones** de las imagenes oficiales (`mysql:8.0.x`, `n8nio/n8n:X.Y.Z`)
2. **Activar el proxy nginx** en `infra/nginx/` con dominios reales y SSL (Certbot/Let's Encrypt)
3. **Usar secretos seguros** — nunca exponer `DB_PASSWORD` o `JWT_SECRET` en logs
4. **Crear un `docker-compose.prod.yml`** con overrides de produccion:
   - `restart: always`
   - Sin mapeo de puertos de MySQL al exterior
   - Variables de entorno desde un gestor de secretos

```bash
# Despliegue en produccion
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Pipeline CI/CD (referencia)

```
Push a main
  │
  ├── 1. Tests (npm run test en contenedores)
  ├── 2. Build imagenes Docker (--no-cache)
  ├── 3. Push a registry (Docker Hub / GitLab Registry)
  └── 4. Deploy en servidor (docker-compose pull + up -d)
```
