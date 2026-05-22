# HU-052 — Documentación del API con Swagger (OpenAPI)

## Asignación de Archivos

`apps/api/src/main.ts` · `apps/api/package.json` · todos los controllers · todos los DTOs

---

## Historia de Usuario

**Como** desarrollador del equipo (o consumidor externo del API),  
**Quiero** una documentación interactiva del API disponible en `/api/docs`,  
**Para** explorar, probar y entender todos los endpoints sin necesidad de Postman ni archivos externos.

**Dependencia:** Requiere HU-040 (Auth) completada. Se beneficia de HU-041 en adelante conforme se agreguen módulos.

---

## Contexto

El API tiene rutas de Auth operativas y seguirá creciendo con Users, Teams, Proyectos, etc. Sin documentación centralizada, cada consumidor debe leer el código fuente para entender los contratos. Swagger + OpenAPI resuelve esto con una UI interactiva que se mantiene sincronizada con el código.

---

## Estructura de Archivos a Modificar / Crear

```
apps/api/
├── package.json                        ← agregar @nestjs/swagger swagger-ui-express
└── src/
    ├── main.ts                         ← configurar SwaggerModule
    ├── swagger/
    │   └── swagger.config.ts           ← DocumentBuilder extraído a archivo propio
    ├── health/
    │   └── health.controller.ts        ← agregar @ApiTags, @ApiOperation, @ApiResponse
    └── modules/
        └── auth/
            ├── infrastructure/controllers/
            │   └── auth.controller.ts  ← @ApiTags, @ApiBearerAuth, @ApiBody, @ApiResponse
            └── application/dtos/
                ├── register.dto.ts     ← @ApiProperty en cada campo
                ├── login.dto.ts        ← @ApiProperty
                ├── oauth-callback.dto.ts
                ├── refresh-token.dto.ts
                ├── change-password.dto.ts
                └── auth-response.dto.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — UI accesible y protegida por entorno

**Dado** que el servidor está corriendo  
**Cuando** se navega a `http://localhost:3000/api/docs`  
**Entonces:**
- Se muestra Swagger UI con título `IA-DataFlow Hub — API`, versión y descripción del proyecto.
- En `NODE_ENV=production` la ruta `/api/docs` retorna 404 (Swagger deshabilitado).
- El esquema OpenAPI JSON está disponible en `/api/docs-json`.

### Escenario 2 — Autenticación Bearer documentada y funcional en UI

**Dado** que Swagger UI está abierta  
**Cuando** el usuario hace login via `POST /api/auth/login` y copia el `access_token`  
**Entonces:**
- Puede pegarlo en el botón **Authorize** (esquema `bearerAuth`).
- Las rutas protegidas (`logout`, `sessions`, `change-password`) muestran el candado cerrado y ejecutan con el token sin necesidad de Postman.

### Escenario 3 — Todos los endpoints documentados con ejemplos

**Dado** que se navega al grupo `Auth` en Swagger  
**Cuando** se expande cualquier endpoint  
**Entonces:**
- Muestra `@ApiOperation` con summary y description.
- Muestra `@ApiBody` con el DTO y sus campos tipados (`@ApiProperty`).
- Muestra todos los posibles `@ApiResponse`: 200/201 éxito, 400 validación, 401 no autenticado, 409 conflicto, 500 error interno.
- Los responses muestran el wrapper estándar `{ success, data, meta }` como ejemplo.

### Escenario 4 — DTOs reflejan validaciones reales

**Dado** que un DTO tiene `@IsEmail()`, `@MinLength(8)`, `@IsOptional()`  
**Cuando** se renderiza en Swagger  
**Entonces:**
- `@ApiProperty` tiene `example`, `description`, `required` y `type` alineados con el decorador de validación.
- Campos opcionales aparecen con `required: false`.

---

## Paquetes a Instalar

```bash
npm install @nestjs/swagger swagger-ui-express --workspace=apps/api
```

> `swagger-ui-express` es el adapter para Express (NestJS usa Express por defecto).

---

## Configuración en `main.ts`

```typescript
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');

  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('IA-DataFlow Hub — API')
      .setDescription('API REST del ecosistema IA-DataFlow. Autenticación, usuarios, proyectos, ETL y más.')
      .setVersion('1.0.0')
      .addBearerAuth(
        { type: 'http', scheme: 'bearer', bearerFormat: 'JWT', in: 'header' },
        'access-token',
      )
      .addTag('Auth', 'Registro, login, OAuth, sesiones y tokens')
      .addTag('Users', 'Perfil y configuración del usuario autenticado')
      .addTag('Health', 'Estado del servicio')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document, {
      swaggerOptions: { persistAuthorization: true },
    });
  }

  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
  await app.listen(process.env.PORT ?? 3000);
}
```

---

## Decoradores por Archivo

### `auth.controller.ts`

```typescript
@ApiTags('Auth')
@Controller('auth')
export class AuthController {

  @Post('register')
  @Public()
  @ApiOperation({ summary: 'Registro con contraseña local' })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({ status: 201, description: 'Usuario creado. Retorna access_token y refresh_token.' })
  @ApiResponse({ status: 400, description: 'Validación fallida (password débil, email inválido).' })
  @ApiResponse({ status: 409, description: 'Email ya registrado.' })

  @Post('login')
  @Public()
  @ApiOperation({ summary: 'Login local con email y contraseña' })
  @ApiResponse({ status: 401, description: 'Credenciales incorrectas.' })

  @Post('oauth/google')
  @Public()
  @ApiOperation({ summary: 'Login/Registro via token de Google' })
  @ApiResponse({ status: 409, description: 'Email ya vinculado a otro proveedor.' })

  @Post('refresh')
  @Public()
  @ApiOperation({ summary: 'Renovar access_token con refresh_token' })
  @ApiResponse({ status: 401, description: 'refresh_token inválido o expirado.' })

  @Post('logout')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Cerrar sesión actual' })

  @Post('change-password')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Cambiar contraseña (valida historial de últimas 5)' })

  @Get('sessions')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Listar sesiones activas del usuario' })

  @Delete('sessions/:id')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Revocar sesión específica por ID' })
  @ApiParam({ name: 'id', description: 'ID de sesión a revocar' })
}
```

### `register.dto.ts` (ejemplo de @ApiProperty)

```typescript
export class RegisterDto {
  @ApiProperty({ example: 'Juan Díaz', description: 'Nombre completo' })
  @IsString()
  fullName: string;

  @ApiProperty({ example: 'juan@dataflow.test', description: 'Email único' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'SecurePass123!', description: 'Mínimo 8 caracteres' })
  @MinLength(8)
  password: string;

  @ApiPropertyOptional({ example: '+573001234567' })
  @IsOptional()
  @IsString()
  phone?: string;
}
```

---

## Wrapper de Respuesta Estándar (para ejemplos en Swagger)

Crear `src/swagger/api-response.wrapper.ts` con clases genéricas que Swagger pueda renderizar:

```typescript
export class ApiSuccessResponse<T> {
  @ApiProperty({ example: true })
  success: boolean;

  data: T;

  @ApiProperty({ example: { timestamp: '2026-05-21T00:00:00Z', path: '/api/...' } })
  meta: Record<string, unknown>;
}

export class ApiErrorResponse {
  @ApiProperty({ example: false })
  success: boolean;

  @ApiProperty({
    example: { code: 'VALIDATION_ERROR', message: 'Campo inválido.', statusCode: 400 },
  })
  error: Record<string, unknown>;

  meta: Record<string, unknown>;
}
```

Usar en controllers:
```typescript
@ApiResponse({ status: 201, type: ApiSuccessResponse })
@ApiResponse({ status: 400, type: ApiErrorResponse })
```

---

## Rutas HTTP Resultantes

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/docs` | Swagger UI (solo non-production) |
| GET | `/api/docs-json` | Esquema OpenAPI 3.0 en JSON |

---

## Tareas

1. [ ] Instalar `@nestjs/swagger` y `swagger-ui-express` en `apps/api`.
2. [ ] Crear `src/swagger/swagger.config.ts` con el `DocumentBuilder`.
3. [ ] Configurar `SwaggerModule` en `main.ts` (condicional por `NODE_ENV`).
4. [ ] Agregar `@ApiProperty` / `@ApiPropertyOptional` a todos los DTOs de Auth.
5. [ ] Decorar `AuthController` con `@ApiTags`, `@ApiOperation`, `@ApiBody`, `@ApiResponse`, `@ApiBearerAuth`.
6. [ ] Decorar `HealthController` con `@ApiTags` y `@ApiOperation`.
7. [ ] Crear `ApiSuccessResponse` y `ApiErrorResponse` genéricos.
8. [ ] Verificar en browser que `/api/docs` carga, el Authorize funciona y todos los endpoints aparecen.
9. [ ] Verificar que en `NODE_ENV=production` la ruta retorna 404.
10. [ ] Al implementar HU-041+, agregar decoradores en cada nuevo controller y DTO siguiendo este mismo patrón.

---

## Notas Técnicas

- `persistAuthorization: true` en `swaggerOptions` guarda el token en localStorage del browser — útil en desarrollo para no re-autenticar en cada recarga.
- El esquema `bearerAuth` se llama `'access-token'` para consistencia con el nombre del token. Todos los endpoints protegidos usan `@ApiBearerAuth('access-token')`.
- No usar `@ApiExcludeEndpoint()` en health ni otros endpoints públicos — todo debe aparecer documentado.
- Cuando se implemente paginación, agregar `@ApiQuery({ name: 'page' })` y `@ApiQuery({ name: 'limit' })` en los endpoints que la soporten.

## Prioridad

**Media** — no bloquea funcionalidad pero mejora significativamente la experiencia del equipo. Implementar después de HU-041.
