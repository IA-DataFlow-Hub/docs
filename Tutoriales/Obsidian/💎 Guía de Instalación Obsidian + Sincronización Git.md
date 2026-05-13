

> [!important] **Antes de empezar**
> Asegúrate de haber completado primero el [[🎓 Manual de Sincronización Git + GitHub]]. Si no tienes Git configurado en tu PC, este tutorial no funcionará.

---

## 1. 📥 Descarga e Instalación

1. Ve a la página oficial: [obsidian.md](https://obsidian.md/).
2. Descarga el instalador para tu sistema operativo.
3. Instala y abre la aplicación.

---

## 2. 📂 Abrir el Proyecto del Equipo

Una vez que hayas clonado el repositorio de GitHub en tu computadora (paso explicado en el manual de Git):

1. En la pantalla de inicio de Obsidian, selecciona **"Open folder as vault"** (Abrir carpeta como bóveda).
2. Busca y selecciona la carpeta que clonaste de GitHub (donde está este archivo).
3. ¡Listo! Ya deberías ver todas las carpetas y notas del equipo.

---

## 3. ⚙️ Configurar la Sincronización Automática

Para que no tengas que usar la terminal y tus cambios se suban solos, instalaremos el plugin **Obsidian Git**.

### Paso A: Activar Plugins de la Comunidad

1. Ve a **Settings** (Icono de engranaje ⚙️) > **Community plugins**.
2. Haz clic en **Turn on community plugins**.

### Paso B: Instalar "Obsidian Git"

1. Haz clic en **Browse** y busca `Obsidian Git`. 
   https://obsidian.md/plugins?id=obsidian-git
2. Haz clic en **Install** y luego en **Enable**.

### Paso C: Configuración de "Modo Invisible"

Dentro de los ajustes del plugin (Settings > Obsidian Git), configura lo siguiente:

| Opción | Valor Recomendado | ¿Qué hace? |
| :--- | :--- | :--- |
| **Vault backup interval** | `5` | Sube tus cambios cada 5 minutos. |
| **Auto pull interval** | `5` | Baja cambios de otros cada 5 minutos. |
| **Pull updates on startup** | `Activado (ON)` | Sincroniza apenas abres la App. |
| **Show status bar** | `Activado (ON)` | Muestra el estado en la barra inferior. |

---

## 🎨 4. Tips de Estilo (Cómo escribir "Bonito")

Para que tus notas se vean como esta, usa estos recursos:

### Enlaces entre notas
Para citar a un compañero o una investigación, usa corchetes dobles:
`[[Juan Diego Mejía Maestre]]` o `[[Manual_Git_Hub]]`.

### Bloques de Colores (Callouts)
Usa esta estructura para resaltar información:

```text
> [!info] Esto es una nota informativa azul.
> [!warning] Esto es una advertencia amarilla.
> [!check] Esto es un éxito o check verde.