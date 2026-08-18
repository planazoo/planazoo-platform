# Marketing — planoon.com

Web comercial del monorepo. **No** es la app Flutter.

- Docs compartidas: `docs/` (ver [MONOREPO.md](../docs/configuracion/MONOREPO.md))
- App producto: raíz Flutter → `https://app.planoon.com`
- Esta carpeta → `https://planoon.com` / `www.planoon.com` (Cloudflare Pages u otro)

## Local

Abrir `index.html` en el navegador, o desde esta carpeta:

```bash
python3 -m http.server 5500
# → http://localhost:5500
```

## Deploy (Cloudflare Pages)

1. dash.cloudflare.com → Workers & Pages → Create → Connect repo (o upload).
2. **Root directory:** `marketing`
3. **Build:** ninguno (estático) · **Output:** `/` (o `.`)
4. Custom domains: `planoon.com` y `www.planoon.com`
5. DNS: CNAME `www` → Pages; apex según indique Cloudflare

## Contenido (fuente de verdad)

Qué debe decir y demostrar la web: [`docs/producto/WEB_COMERCIAL.md`](../docs/producto/WEB_COMERCIAL.md).

Ahí está el relato (Mallorca 2027), los pilares, la capa de verdad (hoy / parcial / visión) y lo que **no** se puede afirmar. El `index.html` es la **maqueta v1** de la home (no el esqueleto inicial). Se construye contra ese brief, no al revés.

Legales: T171 / [`GUIA_ASPECTOS_LEGALES.md`](../docs/guias/GUIA_ASPECTOS_LEGALES.md) cuando existan.

## Stack

HTML/CSS estático a propósito (rápido de desplegar). Si más adelante hace falta framework (Astro, etc.), se añade **dentro de `marketing/`** sin tocar la app.
