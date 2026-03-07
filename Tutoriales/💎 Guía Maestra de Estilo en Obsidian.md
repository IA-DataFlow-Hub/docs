
## 1. Títulos (Jerarquía)

Para que Obsidian entienda que es un título, debe haber un espacio después del `#`.

**Cómo se escribe:**

Markdown

```
# Título Grande
## Título Mediano
### Título Pequeño
```

**Cómo se ve:**

# Título Grande

## Título Mediano

## Título Pequeño

---

## 2. Estilos de Texto

**Cómo se escribe:**

Markdown

```
Yo soy **Juan Diego** y sé de *programación*.
Este es un `comando de git`.
```

**Cómo se ve:** Yo soy **Juan Diego** y sé de _programación_. Este es un `comando de git`.

---

## 3. Listas y Tareas

**Cómo se escribe:**

Markdown

```
- [ ] Tarea por hacer
- [x] Tarea terminada
- Punto normal
	- Subpunto (usando la tecla Tab)
```

**Cómo se ve:**

- [ ] Tarea por hacer
    
- [x] Tarea terminada
    
- Punto normal
    
    - Subpunto
        

---

## 4. Bloques de Colores (Callouts)

> [!danger] **¡Cuidado!** Si no pones el `> [!tipo]`, Obsidian lo verá como un texto normal.

**Cómo se escribe:**

Markdown

```
> [!info] Título Azul
> Este es para información general.

> [!check] Título Verde
> Este es para éxitos o tareas completadas.

> [!warning] Título Amarillo
> Este es para advertencias.

> [!danger] > **Crítico:** Para errores graves o reglas inamovibles.
```

**Cómo se ve:**

> [!info] Título Azul Este es para información general.

> [!check] Título Verde Este es para éxitos o tareas completadas.

> [!warning]  **Advertencia:** Para puntos donde hay que tener cuidado.

> [!danger] **Crítico:** Para errores graves o reglas inamovibles.


## 5. Enlaces (El alma de Obsidian)

**Cómo se escribe:**

Markdown

```
Revisar el perfil de [[Sebastián Bautista Martínez]].
Ver el [Prototipo Web](https://ia-dataflow.codigolimpio.com.co/).
```

**Cómo se ve:** Revisar el perfil de [[Sebastián Bautista Martínez]]. Ver el [Prototipo Web](https://ia-dataflow.codigolimpio.com.co/).

- **Enlace interno:** `[[Nombre de la nota]]` (Conecta con otra nota del equipo).
- **Alias de enlace:** `[[Nota|Texto que se verá]]` (Muestra un nombre distinto al de la nota).
- **Enlace externo:** `[Nombre de la web](URL)` (Ej: [GitHub](https://github.com)).

## 6. 🗂️ Tarjetas y Columnas (Cards)

Para crear el efecto de tarjetas que usamos en la Bienvenida, instalaremos el plugin **"Modular CSS Layout"** o usamos bloques de columnas.

**Estructura básica de tarjeta:**
---
```
> [!card]  
> ### 👤 Nombre del Integrante 
> **Cargo:** Analista TI  
> **Habilidades:** SQL, Python.
```

> [!card]  
> ### 👤 Nombre del Integrante 
> **Cargo:** Analista TI  
> **Habilidades:** SQL, Python.


## 7. Imágenes y PDFs

Para que la imagen se vea dentro de la nota, debes poner el signo de exclamación `!` al principio.

**Cómo se escribe:**

Markdown

```
![[Logo_Proyecto.png]]
![[Documento_Investigacion.pdf]]
```

**Cómo se ve:** _(Aquí aparecería la imagen o el visor de PDF incrustado directamente en la nota)._

---

## 💡 El secreto del "Modo Lectura"

Si ves los símbolos (`#`, `**`, `>`), es porque estás en **Modo Edición**.

- **Presiona `Ctrl + E`**: Verás cómo desaparecen los códigos y aparece el diseño bonito.
    
- **Presiona `Ctrl + Click`** en un nombre entre corchetes `[[ ]]` para viajar a esa nota.