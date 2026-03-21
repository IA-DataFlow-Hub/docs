# 🛠️ Guía de Sincronización del Equipo

> [!important] **Leer antes de empezar**
> Este "Vault" (Bóveda) se sincroniza mediante **GitHub**. Para que el equipo trabaje en armonía, todos debemos seguir estos pasos para evitar pérdida de información.

---

## 1. Configuración Inicial (Solo la primera vez)

Si eres nuevo en el equipo, sigue estos pasos para tener el proyecto en tu computadora:

1. **Instala Git:** Descárgalo en [git-scm.com](https://git-scm.com/).
2. **Clona el repositorio:** Abre una terminal en tu PC y ejecuta:
   `git clone https://github.com/IA-DataFlow-Hub/docs
3. **Abre Obsidian:** Elige "Open folder as vault" y selecciona la carpeta que acabas de clonar.

---

## 2. Instalación del Plugin "Obsidian Git"

Para que no tengas que usar la terminal cada vez que escribas algo:

1. Ve a **Ajustes** (`Ctrl + ,`) > **Community Plugins** > **Browse**.
2. Busca **Obsidian Git** e instálalo. https://obsidian.md/plugins?id=obsidian-git
3. Actívalo (**Enable**).

---

## 3. Configuración Recomendada (Automatización)

Configura el plugin de la siguiente manera para que la sincronización sea invisible:

> [!settings] **Ajustes de Obsidian Git**
> - **Vault backup interval:** `5` (Sube tus cambios automáticamente cada 5 minutos).
> - **Auto pull interval:** `5` (Descarga los cambios de tus compañeros cada 5 minutos).
> - **Pull updates on startup:** `Activado` (Asegura que empieces el día con la última versión).
> - **On backup conflict:** `Pull and merge` (Resuelve conflictos automáticamente).

---

## 🚨 Reglas de Oro del Equipo

1. **No borres archivos de otros:** Si necesitas mover o renombrar una nota de un compañero, avisa primero por el chat.
2. **Cierre de sesión:** Antes de cerrar Obsidian, asegúrate de que el icono de Git en la barra inferior esté en color verde o diga "Synced".
3. **Conflictos:** Si Obsidian te avisa de un "Merge Conflict", contacta a **Sebastián (DBA)** o a **Juan Diego (Dev)** para resolverlo sin perder datos.

---

## ⌨️ Comandos Rápidos (Manual)

Si la automatización falla, usa la paleta de comandos (`Ctrl + P`):
- `Obsidian Git: Pull` → Para traer cambios nuevos.
- `Obsidian Git: Commit and push all changes` → Para subir tu trabajo manualmente.
[[actas]]