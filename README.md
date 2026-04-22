# Detona — Dominio Público México

> La herencia que no sabías que tenías.

Base de datos y motor jurídico del dominio público mexicano.  
Obras registradas en el DOF 1928–1948 verificadas con fundamento legal.

---

## Setup rápido

### 1. Supabase — crear la base de datos

1. Ve a tu proyecto en [supabase.com](https://supabase.com)
2. Abre el **SQL Editor**
3. Copia y ejecuta el contenido de `data/schema.sql`
4. Listo — las tablas `obras`, `autores` y `obras_autores` quedan creadas

### 2. GitHub Pages — publicar el sitio

1. Sube este repositorio a GitHub (usuario: `detona-dp`, repo: `detona-dp`)
2. Ve a **Settings → Pages**
3. En "Source" selecciona `main` / `root`
4. El sitio queda en: `https://detona-dp.github.io/detona-dp/`

### 3. Dominio propio (opcional)

Crea un archivo `CNAME` en la raíz con el contenido:
```
detona.org
```
Y apunta tu DNS a GitHub Pages.

---

## Estructura del proyecto

```
detona/
├── index.html          # Buscador — interfaz principal
├── data/
│   └── schema.sql      # Schema de base de datos Supabase
└── README.md
```

---

## Importar datos

Una vez que el pipeline de extracción de PDFs esté listo, los datos
se importan con un CSV directo a Supabase:

```
Supabase Dashboard → Table Editor → obras → Import CSV
```

O via API con el script de ingesta (pendiente).

---

## Stack

- **Frontend**: HTML/CSS/JS puro — sin dependencias, sin build step
- **Base de datos**: Supabase PostgreSQL (free tier)
- **Hosting**: GitHub Pages (gratuito)
- **Costo total**: $0

---

## Motor jurídico

El campo `ley_aplicable` determina qué ley aplica a cada obra:

| Valor | Ley | Período obras |
|---|---|---|
| `CC1884` | Código Civil 1884 | hasta 1927 |
| `CC1928` | Código Civil 1928 | 1928 |
| `LFDA1948` | LFDA 1948 | 1929–1956 |
| `LFDA1956` | LFDA 1956 | 1957–1996 |

El campo `fundamento_legal` contiene los artículos específicos
que sustentan la determinación de dominio público.

---

detona.org · 2025
