# Monorepo Planoon

Un solo repositorio Git / workspace Cursor para **app** + **web comercial** + **documentación compartida**.

## Estructura

```text
unp_calendario/                 ← raíz del monorepo (nombre histórico del repo)
├── docs/                       ← documentación común (fuente de verdad)
├── marketing/                  ← web comercial → planoon.com / www
├── lib/ ios/ android/ web/     ← app Flutter (iOS, Android, web app)
├── functions/                  ← Cloud Functions
├── firebase.json               ← Hosting de la app (app.planoon.com)
└── …
```

**Por qué Flutter sigue en la raíz:** no hace falta mover `lib/` a `app/` para tener monorepo; las herramientas Flutter/Firebase esperan la raíz actual. `marketing/` es hermano de `docs/` y del código Flutter.

## Qué va dónde

| Pieza | Carpeta | URL / destino |
|-------|---------|----------------|
| Docs, timeline, flujos, legal | `docs/` | — (equipo) |
| App nativa + Flutter web | raíz Flutter | `https://app.planoon.com` |
| Landing / marketing | `marketing/` | `https://planoon.com` / `www` |

## Cursor

1. Abrir **esta carpeta** como workspace (un solo proyecto).
2. Chat de **app** vs chat de **marketing** si quieres foco; ambos leen `docs/`.
3. Cambios de marca, dominio, lanzamiento → actualizar `docs/` y luego código.

## Deploy

| Proyecto | Comando / flujo | Host |
|----------|-----------------|------|
| App web | `flutter build web` + `firebase deploy --only hosting` | Firebase → `app.planoon.com` |
| Marketing | ver `marketing/README.md` | Cloudflare Pages → `planoon.com` / `www` |

**No** apuntar el apex `planoon.com` al Hosting de la app Flutter.

## Referencias

- Dominio: [DOMINIO_PLANOON.md](./DOMINIO_PLANOON.md)
- Timeline (fase 4 landing): [TIMELINE_LANZAMIENTO.md](../producto/TIMELINE_LANZAMIENTO.md)
- Brief de la web comercial: [WEB_COMERCIAL.md](../producto/WEB_COMERCIAL.md)
- Marketing: [`../../marketing/README.md`](../../marketing/README.md)
