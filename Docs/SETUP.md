# Guía de configuración — IA-DataFlow-Hub

Sigue estos pasos **en orden** para tener el proyecto corriendo desde cero.

---

## 1. Prerequisitos

Instala las siguientes herramientas antes de clonar el repo.

### Git
- Descarga: https://git-scm.com/downloads
- Versión mínima: **2.40+**
- Verificar: `git --version`

### Node.js
- Descarga: https://nodejs.org (elige **LTS**, actualmente 20.x)
- Versión mínima: **20.x**
- Verificar: `node --version`

> El proyecto usa `npm@10.2.4` (definido en `package.json > packageManager`).
> npm viene incluido con Node.js. Verificar: `npm --version`

### Docker Desktop
- Descarga: https://www.docker.com/products/docker-desktop
- Versión mínima: **4.20+**
- En Windows: habilitar **WSL 2** backend durante la instalación
- Verificar: `docker --version` y `docker compose version`

### Visual Studio Code
- Descarga: https://code.visualstudio.com
- Ver extensiones recomendadas en [la sección de VS Code](#5-vs-code)

---

## 2. Clonar el repositorio

```bash
git clone <URL-del-repo>
cd IA-DataFlow-Hub
```

---

## 3. Variables de entorno

```bash
# Copia la plantilla
cp .env.example .env
```

Edita `.env` con tus valores reales:

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DB_PASSWORD` | Contraseña de MySQL root | `MiPassword123` |
| `DB_NAME` | Nombre de la base de datos | `ia_dataflow_v4` |
| `DATABASE_URL` | URL Prisma (apunta al puerto 3307 del host) | `mysql://root:MiPassword123@localhost:3307/ia_dataflow_v4` |
| `JWT_SECRET` | Secreto para access tokens | string largo aleatorio |
| `JWT_REFRESH_SECRET` | Secreto para refresh tokens | string largo aleatorio (distinto al anterior) |
| `JWT_EXPIRES_IN` | Duración access token | `15m` |
| `JWT_REFRESH_EXPIRES_IN` | Duración refresh token | `7d` |
| `GOOGLE_CLIENT_ID` | OAuth Google (opcional para login social) | desde Google Cloud Console |
| `AI_ENGINE_URL` | URL de LM Studio corriendo en el host | `http://host.docker.internal:1234/v1` |

> `.env` está en `.gitignore`. **Nunca lo subas al repositorio.**

Para generar secretos JWT seguros:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

---

## 4. Levantar el proyecto

### Instalación de dependencias (solo primera vez o tras cambios en package.json)
```bash
npm install
```

### Levantar todos los servicios con Docker

```bash
# Primera vez o tras cambios en el código fuente (rebuilds las imágenes)
docker compose up --build -d

# Subsecuentes arranques sin cambios de código
docker compose up -d
```

Docker levanta automáticamente:
- La base de datos MySQL
- La API (NestJS)
- El frontend (React/Vite)
- phpMyAdmin
- n8n

### Verificar que todo esté corriendo

```bash
docker compose ps
```

Todos los servicios deben mostrar estado `healthy` o `running`.

---

## URLs de los servicios

| Servicio | URL | Descripción |
|---|---|---|
| Frontend | http://localhost:5173 | Aplicación React |
| API | http://localhost:3000 | Backend NestJS |
| Swagger | http://localhost:3000/api/docs | Documentación API |
| phpMyAdmin | http://localhost:8080 | Administrador MySQL |
| n8n | http://localhost:5678 | Automatización |
| MySQL | `localhost:3307` | Acceso directo desde host |

---

## 5. VS Code

### Extensiones recomendadas

El archivo `.vscode/extensions.json` lista las extensiones recomendadas. VS Code las sugiere automáticamente al abrir el proyecto. También puedes instalarlas manualmente:

| Extensión | ID | Para qué |
|---|---|---|
| ESLint | `dbaeumer.vscode-eslint` | Linting y corrección automática de TypeScript/JavaScript |
| Prettier | `esbenp.prettier-vscode` | Formateo automático de código |
| Prisma | `Prisma.prisma` | Syntax highlighting y soporte de `schema.prisma` |
| Docker | `ms-azuretools.vscode-docker` | Manejo de contenedores, imágenes y Docker Compose |
| NestJS Files | `falvel.vscode-nestjs-files` | Generación rápida de controladores, servicios y módulos NestJS |
| ES7+ React/Redux/React-Native snippets | `dsznajder.es7-react-js-snippets` | Snippets para React, hooks y componentes funcionales |
| GitLens | `eamodio.gitlens` | Git integrado avanzado |
| Tailwind CSS | `bradlc.vscode-tailwindcss` | Autocomplete y linting de clases Tailwind CSS |
| REST Client | `humao.rest-client` | Probar endpoints HTTP sin salir del editor |
| npm Intellisense | `christian-kohler.npm-intellisense` | Autocomplete para imports de paquetes npm |

Estas extensiones cubren los principales stacks del proyecto: Docker, NestJS, TypeScript, React, Prisma y frontend/Vite. También son útiles para mantener el código limpio y navegar rápido por el monorepo.

### Configuración recomendada de workspace

Crea `.vscode/settings.json` si no existe:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

---

## 6. Comandos útiles del día a día

### Docker

```bash
# Ver logs de un servicio específico
docker compose logs api -f
docker compose logs db -f

# Reiniciar un servicio
docker compose restart api

# Detener todos los servicios (mantiene datos)
docker compose down

# Detener y borrar volúmenes (BORRA la base de datos)
docker compose down -v

# Rebuildar solo un servicio
docker compose up --build -d api
```

### Prisma (correr desde apps/api/)

```bash
cd apps/api

# Regenerar el cliente Prisma tras cambios en schema.prisma
npx prisma generate --schema=../../packages/database/schema.prisma

# Abrir Prisma Studio (explorador visual de la BD)
npx prisma studio --schema=../../packages/database/schema.prisma
```

> **Nota:** Las migraciones se aplican automáticamente al levantar Docker.
> El archivo SQL está en `packages/database/migrations/`.

### Desarrollo local sin Docker (solo API)

```bash
cd apps/api
npm run start:dev
```

> Requiere tener MySQL corriendo (puedes usar solo el servicio `db` de Docker:
> `docker compose up -d db`)

---

## 7. Solución de problemas frecuentes

### Puerto 3307 ocupado
MySQL local puede estar corriendo en 3306. El proyecto mapea `3307:3306` para evitar conflictos.
Si 3307 también está ocupado, cambia el puerto en `docker-compose.yml` y en `DATABASE_URL` del `.env`.

### Error al iniciar la base de datos por primera vez
Si el volumen ya existe con datos de una versión anterior:
```bash
docker compose down -v   # Borra el volumen con datos anteriores
docker compose up -d     # Recrea con el schema nuevo
```

### `npm install` falla con errores de permisos (Windows)
Ejecutar la terminal como Administrador o revisar que Node.js esté en el PATH del sistema.

### Prisma Client desactualizado
Tras hacer `git pull` si cambiaron migraciones o el schema:
```bash
cd apps/api
npx prisma generate --schema=../../packages/database/schema.prisma
```

### Versión de TypeScript incorrecta
El proyecto requiere exactamente TypeScript `5.7.3`. Si hay conflictos:
```bash
cd apps/api
npm install  # Instala la versión exacta del package.json
```


---

## Documentos relacionados

**Infraestructura:** [[DOCKERIZACION]] · [[ARQUITECTURA]]
**Apps:** [[api]] · [[client]]
**Paquetes:** [[database]]
**HUs:** [[✅ HU 013 - Configuración de Infraestructura de Datos (Docker)|HU-013]] · [[✅ HU 014 - Arquitectura Base y Monorepo|HU-014]]
