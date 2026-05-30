# DOCUMENTACIÓN TÉCNICA — IA-DataFlow Hub

## Índice

1. [Dependencias y Tecnologías](#1-dependencias-y-tecnologías)
2. [Módulos y Clases Principales del Backend](#2-módulos-y-clases-principales-del-backend)
3. [Endpoints de la API REST](#3-endpoints-de-la-api-rest)
4. [WebSockets y Comunicación en Tiempo Real](#4-websockets-y-comunicación-en-tiempo-real)
5. [Integración con IA](#5-integración-con-ia)
6. [Pipeline de Limpieza con OpenRefine y TOON](#6-pipeline-de-limpieza-con-openrefine-y-toon)
7. [Configuración de n8n](#7-configuración-de-n8n)
8. [Base de Datos — Esquema y Optimizaciones](#8-base-de-datos--esquema-y-optimizaciones)
9. [Guía de Configuración del Entorno](#9-guía-de-configuración-del-entorno)
10. [Variables de Entorno](#10-variables-de-entorno)
11. [Despliegue con Docker Compose](#11-despliegue-con-docker-compose)
12. [Seguridad y Cumplimiento (Ley 1581)](#12-seguridad-y-cumplimiento-ley-1581)
13. [Límites y Escalabilidad](#13-límites-y-escalabilidad)
14. [Datasets de Prueba](#14-datasets-de-prueba)

---

## 1. Dependencias y Tecnologías

### Frontend (React + Vite)

| Paquete | Versión | Propósito |
|---|---|---|
| `react` | ^18 | Framework UI base |
| `vite` | ^5 | Bundler y servidor de desarrollo |
| `recharts` | ^2 | Gráficos modulares básicos (línea, barra, pie) |
| `d3` | ^7 | Visualizaciones avanzadas personalizadas |
| `apexcharts` + `react-apexcharts` | ^3 | Gráficos interactivos con múltiples series |
| `plotly.js` | ^2 | Análisis sofisticado y gráficos 3D |
| `zustand` | ^4 | Gestión de estado global (minimalista) |
| `socket.io-client` | ^4 | WebSockets para streaming en tiempo real |
| `papaparse` | ^5 | Parsing de CSV en streams (archivos pesados) |
| `axios` | ^1 | Cliente HTTP para la API |

**Web Workers:** Se utilizan workers nativos del navegador para dividir archivos grandes en chunks antes de enviarlos al servidor, evitando bloquear el hilo principal de UI.

### Backend (Node.js + NestJS)

| Paquete | Versión | Propósito |
|---|---|---|
| `@nestjs/core` + `@nestjs/common` | ^10 | Framework TypeScript modular |
| `@nestjs/jwt` | ^10 | Autenticación con JSON Web Tokens |
| `@nestjs/passport` | ^10 | Estrategias de autenticación |
| `multer` | ^1 | Recepción de archivos con streaming |
| `socket.io` | ^4 | Servidor WebSocket |
| `@google/generative-ai` | ^0.7 | SDK de Google Gemini |
| `ollama` | ^0.5 | Cliente para Llama 4 vía Ollama |
| `typeorm` | ^0.3 | ORM para MySQL/PostgreSQL |
| `mysql2` | ^3 | Driver MySQL |
| `pg` | ^8 | Driver PostgreSQL |
| `ioredis` | ^5 | Cliente Redis para colas y cache |
| `bull` | ^4 | Sistema de colas sobre Redis |
| `class-validator` | ^0.14 | Validación de DTOs |
| `bcrypt` | ^5 | Hash de contraseñas |
| `@nestjs/config` | ^3 | Gestión de variables de entorno |
| `axios` | ^1 | HTTP client para webhooks a n8n |

### Infraestructura

| Servicio | Imagen Docker | Puerto | Propósito |
|---|---|---|---|
| NestJS API | `node:18-alpine` | 4000 | Backend principal |
| React App | `node:18-alpine` + nginx | 3000 | Servidor de frontend |
| n8n | `n8nio/n8n:latest` | 5678 | Orquestador de flujos |
| Ollama | `ollama/ollama:latest` | 11434 | Servidor de modelos IA locales |
| OpenRefine | `openrefine/openrefine:3.7` | 3333 | Limpieza de datos con GREL |
| MySQL | `mysql:8.0` | 3306 | Base de datos principal |
| PostgreSQL | `postgres:15-alpine` | 5432 | Base de datos para bulk insert |
| Redis | `redis:7-alpine` | 6379 | Colas de procesamiento y cache |

---

## 2. Módulos y Clases Principales del Backend

La arquitectura NestJS está organizada en módulos desacoplados. Cada módulo encapsula controladores, servicios y entidades propias.

### `AuthModule`

**Responsabilidad:** Registro, autenticación y autorización de usuarios.

```typescript
// Clases principales
AuthController       // POST /auth/register, POST /auth/login, GET /auth/me
AuthService          // Lógica de negocio: hash bcrypt, generación de JWT
JwtStrategy          // Validación de tokens en rutas protegidas
JwtAuthGuard         // Guard aplicable con @UseGuards(JwtAuthGuard)
RolesGuard           // Autorización basada en roles (admin, analista, viewer)
```

**Flujo:**
1. Usuario envía `email + password` a `POST /auth/login`
2. `AuthService` valida credenciales con `bcrypt.compare()`
3. Genera JWT firmado con `JWT_SECRET` y expiración configurable
4. El token se incluye en el header `Authorization: Bearer <token>` de cada solicitud

### `DatasetModule`

**Responsabilidad:** Gestión del ciclo de vida de archivos de datos.

```typescript
DatasetController    // Endpoints de carga, preview, análisis
DatasetService       // Recepción con Multer, chunking, validación
DatasetRepository    // Persistencia con TypeORM
Dataset              // Entidad: id, nombre, formato, tamanio_bytes, estado, ruta
```

**Multer Configuration:**
```typescript
MulterModule.registerAsync({
  useFactory: () => ({
    storage: diskStorage({
      destination: './uploads/temp',
      filename: (req, file, cb) => cb(null, `${uuid()}-${file.originalname}`)
    }),
    limits: { fileSize: 500 * 1024 * 1024 }, // 500 MB
    fileFilter: (req, file, cb) => {
      const allowed = ['text/csv', 'application/vnd.ms-excel',
                       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                       'application/json'];
      cb(null, allowed.includes(file.mimetype));
    }
  })
})
```

### `AIService`

**Responsabilidad:** Orquestar llamadas a modelos de IA locales y en la nube.

```typescript
class AIService {
  // IA Local — datos sensibles
  async analyzeWithLlama(data: string, systemPrompt: string): Promise<string>
  async anonymizePII(text: string): Promise<{ anonymized: string; mapping: PIIMapping }>

  // IA Nube — procesamiento masivo
  async analyzeWithGemini(data: string, rules: BusinessRule[]): Promise<AnalysisResult>
  async deduplicateWithGemini(rows: DataRow[]): Promise<DataRow[]>

  // Compresión TOON antes de enviar a nube
  private applyTOONCompression(text: string): string

  // Chat conversacional para el usuario
  async chat(message: string, context: DatasetContext): Promise<string>
}
```

**System Prompts base:**
- **Análisis:** `"Eres un experto en calidad de datos. Analiza el siguiente dataset e identifica: duplicados, valores nulos, inconsistencias de formato, outliers estadísticos y anomalías semánticas..."`
- **Anonimización:** `"Detecta y reemplaza toda información de identificación personal (PII) con tokens hash. Retorna el texto anonimizado y un mapa de reemplazo en JSON..."`
- **Limpieza:** `"Aplica las siguientes reglas de negocio al dataset. Para cada fila modificada, explica qué cambió y por qué..."`

### `N8nOrchestrationService`

**Responsabilidad:** Comunicación con n8n vía webhooks HTTP.

```typescript
class N8nOrchestrationService {
  async triggerETLPipeline(datasetId: number, options: ETLOptions): Promise<void>
  async triggerCleaning(datasetId: number, rules: CleaningRule[]): Promise<void>
  async getFlowStatus(executionId: string): Promise<FlowStatus>
  async cancelFlow(executionId: string): Promise<void>

  private buildWebhookPayload(event: string, data: object): WebhookPayload
  private async postToN8N(endpoint: string, payload: object): Promise<AxiosResponse>
}
```

### `TransformationService`

**Responsabilidad:** Aplicar transformaciones de datos usando OpenRefine + GREL.

```typescript
class TransformationService {
  async applyGRELExpression(datasetId: number, column: string, expression: string): Promise<void>
  async clusterAndMerge(datasetId: number, column: string, method: ClusterMethod): Promise<void>
  async normalizeFormats(datasetId: number, schema: SchemaDefinition): Promise<void>
  async rollback(transformationId: number): Promise<void>
}

// Expresiones GREL comunes
const GREL_EXPRESSIONS = {
  TRIM_SPACES: 'value.trim()',
  UPPERCASE: 'value.toUppercase()',
  DATE_FORMAT: 'value.toDate("dd/MM/yyyy").toString("yyyy-MM-dd")',
  REMOVE_DUPLICATES: 'row.index == row.cells["id"].value.facetCount(...) - 1',
  PHONE_FORMAT: 'value.replace(/[^0-9]/g, "").replace(/(.{3})(.{3})(.{4})/, "$1-$2-$3")'
}
```

### `ReportService`

**Responsabilidad:** Generar y exportar reportes hacia Power BI.

```typescript
class ReportService {
  async generateReport(datasetId: number, type: DashboardType): Promise<Report>
  async exportToPowerBI(reportId: number): Promise<PowerBIDataset>
  async getReportHistory(datasetId: number): Promise<Report[]>
}

enum DashboardType {
  STRATEGIC  = 'strategic',  // KPIs globales para C-Level
  TACTICAL   = 'tactical',   // Métricas por área para gestores
  TECHNICAL  = 'technical',  // Calidad de datos para analistas
  OPERATIONAL = 'operational' // Tareas y alertas para ejecutores
}
```

---

## 3. Endpoints de la API REST

Base URL: `http://localhost:4000/api`

### Autenticación

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| `POST` | `/auth/register` | No | Registro de nuevo usuario |
| `POST` | `/auth/login` | No | Login, retorna JWT |
| `GET` | `/auth/me` | JWT | Perfil del usuario autenticado |
| `POST` | `/auth/refresh` | JWT | Renovar token |

**Body `/auth/login`:**
```json
{
  "email": "usuario@empresa.com",
  "password": "contraseña_segura"
}
```

**Response `/auth/login`:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 86400,
  "user": { "id": 1, "email": "usuario@empresa.com", "roles": ["analista"] }
}
```

### Proyectos

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| `GET` | `/projects` | JWT | Listar proyectos del usuario |
| `POST` | `/projects` | JWT | Crear proyecto |
| `GET` | `/projects/:id` | JWT | Detalles de un proyecto |
| `PUT` | `/projects/:id` | JWT | Actualizar proyecto |
| `DELETE` | `/projects/:id` | JWT | Archivar proyecto |

### Datasets

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| `POST` | `/datasets/upload` | JWT | Cargar archivo (multipart/form-data) |
| `GET` | `/datasets/:id` | JWT | Metadatos del dataset |
| `GET` | `/datasets/:id/preview` | JWT | Vista previa de las primeras 100 filas |
| `POST` | `/datasets/:id/analyze` | JWT | Iniciar análisis con IA |
| `POST` | `/datasets/:id/clean` | JWT | Ejecutar limpieza automática |
| `POST` | `/datasets/:id/transform` | JWT | Aplicar transformación manual |
| `GET` | `/datasets/:id/history` | JWT | Historial de transformaciones |
| `POST` | `/datasets/:id/rollback/:transformId` | JWT | Revertir una transformación |
| `DELETE` | `/datasets/:id` | JWT | Eliminar dataset |

**Body `/datasets/:id/clean`:**
```json
{
  "rules": [
    { "type": "remove_duplicates", "columns": ["email", "documento"] },
    { "type": "fill_nulls", "column": "ciudad", "strategy": "mode" },
    { "type": "normalize_format", "column": "fecha", "format": "YYYY-MM-DD" },
    { "type": "trim_whitespace", "columns": ["nombre", "apellido"] }
  ],
  "useLocalAI": true,
  "compressionTOON": true
}
```

### Inteligencia Artificial

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| `POST` | `/ai/chat` | JWT | Chat conversacional con el asistente |
| `POST` | `/ai/analyze-quality` | JWT | Análisis de calidad del dataset |
| `POST` | `/ai/extract-entities` | JWT | Extracción de entidades del texto |
| `POST` | `/ai/suggest-rules` | JWT | Sugerencias automáticas de limpieza |

**Body `/ai/chat`:**
```json
{
  "message": "¿Cuántos duplicados tiene mi dataset?",
  "datasetId": 42,
  "model": "gemini"
}
```

### Reportes

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| `GET` | `/reports/dataset/:datasetId` | JWT | Listar reportes de un dataset |
| `POST` | `/reports/generate` | JWT | Generar nuevo reporte |
| `GET` | `/reports/:id` | JWT | Obtener datos del reporte |
| `POST` | `/reports/:id/export/powerbi` | JWT | Exportar a Power BI |
| `GET` | `/reports/:id/download` | JWT | Descargar reporte en PDF/Excel |

---

## 4. WebSockets y Comunicación en Tiempo Real

El servidor WebSocket corre en `ws://localhost:4000/socket` utilizando Socket.IO.

### Eventos del Servidor → Cliente

| Evento | Payload | Descripción |
|---|---|---|
| `analysis:started` | `{ datasetId, timestamp }` | Análisis IA iniciado |
| `analysis:progress` | `{ datasetId, percent, message }` | Progreso del análisis |
| `analysis:completed` | `{ datasetId, result: AnalysisResult }` | Análisis terminado |
| `cleaning:started` | `{ datasetId }` | Limpieza iniciada |
| `cleaning:progress` | `{ datasetId, rowsProcessed, total }` | Progreso fila por fila |
| `cleaning:completed` | `{ datasetId, stats: CleaningStats }` | Limpieza terminada |
| `ai:message` | `{ content, role, datasetId }` | Mensaje de chat en streaming |
| `error` | `{ code, message, datasetId }` | Error en cualquier proceso |

### Eventos del Cliente → Servidor

| Evento | Payload | Descripción |
|---|---|---|
| `subscribe:dataset` | `{ datasetId }` | Suscribirse a notificaciones de un dataset |
| `unsubscribe:dataset` | `{ datasetId }` | Cancelar suscripción |
| `chat:send` | `{ message, datasetId }` | Enviar mensaje al asistente IA |

---

## 5. Integración con IA

### Llama 4 — IA Local (Datos Privados)

**Endpoint Ollama:** `http://ollama:11434`

```typescript
// Configuración de conexión
const ollama = new Ollama({ host: process.env.OLLAMA_BASE_URL });

// Llamada básica
const response = await ollama.chat({
  model: 'llama4',
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userMessage }
  ],
  stream: false,
  options: { temperature: 0.1, num_ctx: 4096 }
});
```

**Casos de uso exclusivos para Llama 4:**
- Detección y anonimización de PII (nombres, DNI, correos, teléfonos)
- Procesamiento de datasets con cláusulas de confidencialidad
- Análisis inicial de estructura antes de decidir qué enviar a la nube

**Modelos instalados en Ollama:**
```bash
ollama pull llama4          # Modelo principal (chat y análisis)
ollama pull nomic-embed-text # Embeddings para búsqueda semántica
```

### Gemini 2.5 Flash-Lite — IA en Nube

**SDK:** `@google/generative-ai`

```typescript
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({
  model: 'gemini-2.5-flash-lite',
  generationConfig: {
    temperature: 0.1,
    maxOutputTokens: 8192,
    responseMimeType: 'application/json'
  }
});

const result = await model.generateContent([
  { text: systemPrompt },
  { text: toonCompressedData }
]);
```

**Casos de uso para Gemini:**
- Deduplicación de 100k+ registros en batch
- Normalización masiva de formatos
- Análisis semántico de texto libre
- Generación de sugerencias de limpieza

**Costo estimado:**
| Volumen | Costo Gemini 2.5 Flash-Lite |
|---|---|
| 10,000 registros | ~$1.13 USD |
| 50,000 registros | ~$5.63 USD |
| 100,000 registros | ~$11.25 USD |

### Compresión TOON

El estándar TOON (Text Optimization for Online Networks) reduce el tamaño del texto enviado a la IA en un **45 %** mediante:

- Eliminación de palabras vacías (stop words)
- Abreviatura de términos frecuentes
- Codificación posicional de columnas
- Omisión de valores repetidos

```typescript
function applyTOONCompression(text: string): string {
  return text
    .replace(/\b(the|a|an|is|are|was|were|and|or|but|in|on|at|to|for|of|with)\b/gi, '')
    .replace(/\s+/g, ' ')
    .replace(/(\w+)\1+/g, '$1')
    .trim();
}
```

---

## 6. Pipeline de Limpieza con OpenRefine y TOON

### Flujo de OpenRefine vía API

OpenRefine expone una API HTTP REST en `http://openrefine:3333`.

```typescript
// 1. Crear proyecto desde dataset
POST /command/core/create-project-from-upload
  Body: multipart con el archivo CSV/Excel

// 2. Aplicar operaciones GREL
POST /command/core/apply-operations
  Body: { "project": projectId, "operations": [...] }

// 3. Exportar resultado
GET /command/core/export-rows
  Params: { project: projectId, engine: {}, format: "csv" }
```

### Operaciones GREL Comunes

```json
[
  {
    "op": "core/mass-edit",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "nombre",
    "expression": "grel:value.trim().toUppercase()",
    "edits": []
  },
  {
    "op": "core/column-removal",
    "columnName": "columna_vacia"
  },
  {
    "op": "core/key-value-columnize",
    "keyColumnName": "id",
    "valueColumnName": "valor"
  }
]
```

### Clustering para Deduplicación

OpenRefine ofrece cuatro métodos de clustering:

| Método | Uso recomendado |
|---|---|
| `fingerprint` | Nombres con typos menores |
| `ngram-fingerprint` | Textos cortos con variaciones |
| `levenshtein` | Distancia de edición (más preciso) |
| `ppm` | Texto libre con variaciones fonéticas |

---

## 7. Configuración de n8n

n8n actúa como el orquestador central que conecta todos los servicios.

### Flujos principales (Workflows)

| Workflow | Trigger | Descripción |
|---|---|---|
| `ETL Pipeline` | Webhook: `POST /webhook/etl-start` | Pipeline completo desde carga hasta persistencia |
| `AI Analysis` | Webhook: `POST /webhook/analyze` | Análisis con Llama 4 + Gemini |
| `Data Cleaning` | Webhook: `POST /webhook/clean` | Limpieza con OpenRefine + reglas IA |
| `Report Generation` | Cron: cada hora | Actualización automática de dashboards |
| `Error Handler` | Error trigger | Notificación y reintento ante fallos |

### Estructura de Webhook de Entrada

```json
{
  "event": "etl-start",
  "datasetId": 42,
  "projectId": 7,
  "userId": 1,
  "options": {
    "useLocalAI": true,
    "compressionTOON": true,
    "targetDB": "mysql",
    "cleaningRules": []
  },
  "callbackUrl": "http://backend:4000/api/n8n/callback"
}
```

### Callback del Pipeline

Cuando n8n termina un flujo, llama a `POST /api/n8n/callback` con:

```json
{
  "executionId": "abc123",
  "datasetId": 42,
  "status": "success",
  "stats": {
    "rowsInput": 1000,
    "rowsOutput": 987,
    "duplicatesRemoved": 13,
    "nullsFilled": 45,
    "transformationsApplied": 8,
    "processingTimeMs": 12450
  }
}
```

---

## 8. Base de Datos — Esquema y Optimizaciones

### Tablas Principales (MySQL)

```sql
-- Usuarios
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nombre VARCHAR(255),
  organizacion VARCHAR(255),
  activo BOOLEAN DEFAULT TRUE,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Datasets
CREATE TABLE datasets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proyecto_id INT NOT NULL,
  nombre_archivo VARCHAR(500),
  formato ENUM('csv','excel','json','log'),
  tamanio_bytes BIGINT,
  total_filas INT,
  total_columnas INT,
  estado_procesamiento ENUM('pendiente','procesando','completado','error'),
  fecha_carga DATETIME DEFAULT CURRENT_TIMESTAMP,
  ruta_almacenamiento VARCHAR(1000),
  FOREIGN KEY (proyecto_id) REFERENCES projects(id)
);

-- Historial de Transformaciones
CREATE TABLE transformations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dataset_id INT NOT NULL,
  tipo_operacion VARCHAR(100),
  parametros_json JSON,
  filas_afectadas INT,
  reversible BOOLEAN DEFAULT TRUE,
  motor_ia VARCHAR(50),
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (dataset_id) REFERENCES datasets(id)
);
```

### Índices Recomendados

```sql
CREATE INDEX idx_datasets_proyecto ON datasets(proyecto_id);
CREATE INDEX idx_datasets_estado ON datasets(estado_procesamiento);
CREATE INDEX idx_transformations_dataset ON transformations(dataset_id);
CREATE INDEX idx_transformations_timestamp ON transformations(timestamp);
CREATE INDEX idx_users_email ON users(email);
```

### Bulk Insert en PostgreSQL

Para datasets mayores de 50,000 filas se prefiere PostgreSQL por su rendimiento con `COPY`:

```sql
-- Tiempo: ~30 segundos para 100k filas vs ~10 minutos con INSERT individual
COPY datasets_data (col1, col2, col3, ...)
FROM '/tmp/dataset_clean.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
```

---

## 9. Guía de Configuración del Entorno

### Requisitos de Sistema

| Componente | Mínimo | Recomendado |
|---|---|---|
| RAM | 12 GB | 16-32 GB |
| CPU | 4 vCPU a 2.6 GHz | 8+ vCPU |
| Almacenamiento | 100 GB SSD | 250+ GB SSD NVMe |
| GPU | Opcional | NVIDIA VRAM 16 GB+ |
| SO | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |

### Instalación Local (Desarrollo)

```bash
# 1. Clonar repositorio
git clone https://github.com/IA-DataFlow-Hub/api.git
cd api

# 2. Instalar dependencias del backend
npm install

# 3. Copiar y configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# 4. Instalar y configurar Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama4
ollama pull nomic-embed-text

# 5. Levantar servicios con Docker
docker compose up -d mysql postgres redis n8n openrefine

# 6. Ejecutar migraciones
npm run migration:run

# 7. Iniciar servidor de desarrollo
npm run start:dev
```

### Instalación Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
# Configurar VITE_API_URL=http://localhost:4000/api
npm run dev
```

---

## 10. Variables de Entorno

```env
# ==========================================
# SERVIDOR
# ==========================================
PORT=4000
NODE_ENV=development

# ==========================================
# AUTENTICACIÓN
# ==========================================
JWT_SECRET=reemplaza_con_clave_aleatoria_segura_256bits
JWT_EXPIRATION=24h

# ==========================================
# BASE DE DATOS MYSQL (Principal)
# ==========================================
DB_HOST=localhost
DB_PORT=3306
DB_USER=iaflow_user
DB_PASSWORD=contraseña_mysql
DB_NAME=iaflow_db

# ==========================================
# BASE DE DATOS POSTGRESQL (Bulk Insert)
# ==========================================
PG_HOST=localhost
PG_PORT=5432
PG_USER=iaflow_user
PG_PASSWORD=contraseña_postgres
PG_NAME=iaflow_bulk

# ==========================================
# REDIS
# ==========================================
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=

# ==========================================
# IA — MODELOS EN NUBE
# ==========================================
GEMINI_API_KEY=AIzaSy...
OPENAI_API_KEY=sk-...           # Alternativa GPT-4o mini

# ==========================================
# IA — MODELOS LOCALES (Ollama)
# ==========================================
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL_CHAT=llama4
OLLAMA_MODEL_EMBED=nomic-embed-text

# ==========================================
# n8n (Orquestador)
# ==========================================
N8N_WEBHOOK_BASE_URL=http://localhost:5678/webhook
N8N_API_KEY=tu_api_key_de_n8n
N8N_USER=admin
N8N_PASSWORD=contraseña_n8n

# ==========================================
# OPENREFINE
# ==========================================
OPENREFINE_URL=http://localhost:3333

# ==========================================
# SEGURIDAD Y PRIVACIDAD (Ley 1581)
# ==========================================
ENCRYPT_SENSITIVE_DATA=true
DATA_RETENTION_DAYS=90
PII_DETECTION_ENABLED=true
LOCAL_AI_FOR_SENSITIVE=true

# ==========================================
# ALMACENAMIENTO
# ==========================================
UPLOAD_MAX_SIZE_MB=500
UPLOAD_TEMP_DIR=./uploads/temp
UPLOAD_PROCESSED_DIR=./uploads/processed
```

---

## 11. Despliegue con Docker Compose

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    build: ./backend
    ports:
      - "4000:4000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    depends_on:
      - mysql
      - postgres
      - redis
      - ollama
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped

  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=n8n
      - WEBHOOK_URL=http://n8n:5678
    volumes:
      - n8n_data:/home/node/.n8n
    restart: unless-stopped

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

  openrefine:
    image: openrefine/openrefine:3.7
    ports:
      - "3333:3333"
    volumes:
      - openrefine_data:/data
    restart: unless-stopped

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ${PG_USER}
      POSTGRES_PASSWORD: ${PG_PASSWORD}
      POSTGRES_DB: ${PG_NAME}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  mysql_data:
  postgres_data:
  redis_data:
  n8n_data:
  ollama_models:
  openrefine_data:
```

---

## 12. Seguridad y Cumplimiento (Ley 1581)

### Principios Implementados

| Principio | Implementación |
|---|---|
| **Finalidad** | Datos procesados únicamente para el propósito declarado por el usuario |
| **Libertad** | Consentimiento explícito antes de cualquier procesamiento |
| **Veracidad** | IA reporta cambios realizados con trazabilidad completa |
| **Transparencia** | Historial de transformaciones visible y auditable |
| **Acceso y Circulación** | PII nunca sale del servidor (procesamiento local con Llama 4) |
| **Seguridad** | JWT, bcrypt, HTTPS, cifrado AES-256 para datos en reposo |
| **Confidencialidad** | Variables de entorno para credenciales, secretos nunca en código |

### Retención de Datos

```typescript
// Política: datos eliminados automáticamente tras 90 días
// Configurable con DATA_RETENTION_DAYS en .env
@Cron('0 2 * * *') // Todos los días a las 2 AM
async cleanupExpiredData() {
  const cutoffDate = subDays(new Date(), parseInt(process.env.DATA_RETENTION_DAYS));
  await this.datasetRepository.delete({
    fechaCarga: LessThan(cutoffDate),
    estado: 'completado'
  });
}
```

### Detección de PII

El sistema detecta automáticamente:
- Números de cédula / documento de identidad colombiano
- Direcciones de correo electrónico
- Números de teléfono (formato colombiano)
- Nombres propios (mediante NER de Llama 4)
- Coordenadas geográficas precisas
- Números de tarjetas de crédito / cuentas bancarias

---

## 13. Límites y Escalabilidad

### Límites con Llama 4 Local (Hardware del servidor)

| Usuarios Concurrentes | RAM Usada | Comportamiento |
|---|---|---|
| 1-5 | ~8 GB | Fluido, respuestas en ~3s |
| 10 | ~10 GB | Aceptable, colas leves |
| 30 | ~16 GB | Degradado, colas significativas |
| 50+ | >16 GB | Out of Memory — instancias caen |

### Estrategias de Escalabilidad

1. **Horizontal:** Múltiples instancias de Ollama en servidores con GPU distintas
2. **Colas con prioridad:** Redis + Bull para gestionar picos de demanda
3. **Fallback automático:** Si Llama 4 está saturado, redirigir a Gemini (solo datos no sensibles)
4. **Cache de respuestas:** Cachear en Redis análisis de datasets idénticos (hash MD5 del archivo)

### Opciones de Infraestructura

| Proveedor | Plan | Specs | Costo Mensual |
|---|---|---|---|
| **Hostinger VPS** | KVM4 (recomendado) | 16 GB RAM / 4 vCPU / 200 GB NVMe | $143,900 COP |
| DigitalOcean | Premium Intel | 16 GB RAM / 4 vCPU | ~$96 USD |
| AWS Lightsail | Bundle 16GB | 16 GB RAM / 4 vCPU / 320 GB SSD | ~$80 USD |

---

## 14. Datasets de Prueba

Ubicados en `DataSets/Buscados/`, disponibles para validar el pipeline ETL:

### CSV de Prueba

| Archivo | Filas | Tipo de Error | Caso de Prueba |
|---|---|---|---|
| `csv_1000_datos_duplicados_1.csv` | 1,000 | Duplicados exactos | Deduplicación |
| `datos_erroneos_150_registros.csv` | 150 | Nulos, tipos incorrectos | Limpieza básica |
| `datos_muy_erroneos_muchas_columnas.csv` | ~500 | Columnas extra, datos mixtos | Normalización de esquema |
| `ventas_entorno_pruebas_1.csv` | ~800 | Datos de ventas con errores | Test de transformación |
| `ventas_entorno_pruebas_2.csv` | ~1,000 | Variante de escenario de ventas | Regresión ETL |

### Logs del Sistema

Útiles para probar el módulo de análisis de texto libre:

- `Android.log` + `Android_structured.log` — Logs de sistema Android
- `Apache.log` + `Apache_templates.log` — Logs de servidor web Apache
- `HDFS.log` + `HDFS_structured.log` — Logs de Hadoop Distributed File System

### Estructura del JSON de Salida

El archivo `data-__OHfgszMB8Z8gqkaiBVK.json` representa un ejemplo de la salida estructurada que IA-DataFlow entrega al frontend y a Power BI.

```json
{
  "datasetId": 42,
  "processedAt": "2026-04-15T14:32:00Z",
  "stats": {
    "rowsInput": 1000,
    "rowsOutput": 987,
    "duplicatesRemoved": 13,
    "nullsFilled": 45
  },
  "qualityScore": 94.2,
  "transformations": [...],
  "preview": [...]
}
```


---

## Documentos relacionados

**Arquitectura:** [[ARQUITECTURA]] · [[DOCKERIZACION]] · [[SETUP]]
**Apps & paquetes:** [[api]] · [[database]]
**Diagramas:** [[03-modelo-base-de-datos]] · [[04-flujo-autenticacion]] · [[05-roles-y-permisos]] · [[06-flujo-etl]] · [[07-ciclo-vida-ai-job]] · [[09-privacidad-ley-1581]] · [[10-flujo-conversaciones-chat]]
**HUs clave:** [[✅ HU 040 - Módulo Auth y Gestión de Sesiones|HU-040]] · [[HU 042 - Módulo Teams y Control de Acceso RBAC|HU-042]] · [[✅ HU 048 - Módulo ETL y Tablas Generadas|HU-048]] · [[HU 051 - Módulo Auditoría|HU-051]]
