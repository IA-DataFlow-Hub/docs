

> [!info] **Objetivo**
> Este manual contiene todo lo necesario para configurar tu entorno de trabajo y colaborar en el repositorio de **IA-DataFlow Hub** sin errores.

---

## 1. 📥 Instalación de Git

Git es la herramienta que permite registrar cada cambio que hacemos.

1. **Descarga:** Ve a [git-scm.com](https://git-scm.com/) y descarga la versión para tu sistema (Windows, Mac o Linux).
2. **Instalación:** Ejecuta el instalador. Puedes dejar todas las opciones por defecto ("Next" a todo).
3. **Verificación:** Abre una terminal (CMD o PowerShell) y escribe:
   `git --version`

---

## 2. ☁️ Cuenta de GitHub

1. Regístrate en [github.com](https://github.com/).
2. Informa tu nombre de usuario al administrador del proyecto para que te añada como **Colaborador** al repositorio privado.

---

## 3. 🔑 Conexión Segura (SSH)

Para que no tengas que escribir tu usuario y contraseña cada vez que subas un cambio, configuraremos una "llave" de acceso rápido.

1. **Generar la llave:** Abre la terminal y pega esto (usa tu correo de GitHub):
   `ssh-keygen -t ed25519 -C "tu-correo@ejemplo.com"`
   *(Pulsa Enter a todo lo que te pida).*
2. **Copiar la llave:** - En Windows: `clip < ~/.ssh/id_ed25519.pub`
   - En Mac/Linux: `cat ~/.ssh/id_ed25519.pub`
3. **Pegar en GitHub:** - Ve a GitHub > Configuración (Settings) > **SSH and GPG keys**.
   - Haz clic en **New SSH Key**, ponle un nombre (ej. "Mi PC Trabajo") y pega el código.



---

## 🔄 4. Flujo de Trabajo (Comandos Básicos)

### A. Clonar el proyecto (Solo la primera vez)
`git clone git@github.com:IA-DataFlow-Hub/docs.git 

### B. El ciclo diario
Sigue estos 3 pasos cada vez que termines de trabajar:

1. **Preparar:** `git add .` (Indica que quieres subir todos tus cambios).
2. **Comentar:** `git commit -m "Descripción de lo que hiciste"` (Ej: "Agregué acta de hoy").
3. **Subir:** `git push origin main` (Envía tus notas a la nube).

> [!tip] **Regla de Oro**
> Antes de empezar a escribir, usa siempre `git pull` para bajar lo que tus compañeros hayan subido mientras tú no estabas.



---

## ⚠️ 5. Resolución de Conflictos

Si dos personas editan la misma línea, Git se detendrá. No entres en pánico, se resuelve así:

1. Verás marcas en tu texto como estas: `<<<<<<< HEAD`.
2. **Limpia el archivo:** Borra las marcas y deja solo el texto que deba quedar (puedes combinar ambas ideas).
3. **Finaliza:** `git add .`
   `git commit -m "Conflicto resuelto en acta X"`
   `git push origin main`

---

## ⌨️ Tabla de Comandos Rápidos

| Comando | ¿Para qué sirve? |
| :--- | :--- |
| `git pull` | **Traer** cambios de la nube (Bajar). |
| `git push` | **Enviar** tus cambios a la nube (Subir). |
| `git status` | Ver qué archivos has modificado y no has subido. |
| `git log` | Ver el historial de quién ha hecho cambios. |

---
> [!check] **¿Necesitas ayuda?**
> Si algo falla, contacta a **Juan Diego Mejía Maestre** o **Sebastián Bautista Martínez** en el canal de soporte técnico.

> [!important] **Antes de empezar**
> Asegúrate de haber completado primero el [[Manual_Git_Hub|Manual de Instalación de Git y SSH]]. Si no tienes Git configurado en tu PC, este tutorial no funcionará.