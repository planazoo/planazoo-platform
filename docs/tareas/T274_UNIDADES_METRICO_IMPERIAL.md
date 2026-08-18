# T274 – Sistema métrico/imperial por usuario

**Objetivo:** Permitir que cada usuario elija unidades **métricas** o **imperiales** y que la app muestre los valores en su sistema preferido (especialmente para UK/USA), manteniendo consistencia en web, iOS y Android.

**Relacionado con:** T158 (multi-idioma), T232 (perfil), T257 (paridad iOS/web), T267 (Android).

---

## Contexto

- Hoy no hay una preferencia explícita de unidades por usuario.
- Para usuarios internacionales, el sistema de unidades afecta legibilidad y confianza (ej. millas vs kilómetros, Fahrenheit vs Celsius).
- Debemos evitar romper datos existentes: la preferencia debe impactar **visualización/entrada**, no invalidar históricos.

## Alcance funcional (MVP)

1. Añadir preferencia de unidades en perfil:
   - `metric` (default)
   - `imperial`
2. Persistencia de preferencia por usuario (Firestore; réplica local si aplica al flujo actual de perfil).
3. Mostrar unidades según preferencia en superficies relevantes.
4. Fallback seguro a métrico para usuarios sin preferencia.
5. Cobertura l10n ES/EN para labels/ayudas de esta preferencia.

## Magnitudes objetivo (fasear)

### Fase 1 (obligatoria)
- Distancia: `km` <-> `mi`.

### Fase 2 (si aplica en UI actual)
- Temperatura: `C` <-> `F`.
- Altitud/altura/longitud: `m` <-> `ft`.
- Peso: `kg` <-> `lb`.

> Si alguna magnitud no se usa hoy en producto, no se fuerza en MVP: se deja preparada la capa de conversión.

## Reglas de datos y conversión

- Mantener una base canónica estable para almacenamiento (definir por tipo de campo al implementar).
- Convertir en presentación/entrada de UI según preferencia.
- Definir rounding consistente por magnitud (ej. distancia con 1 decimal donde tenga sentido).
- No mezclar unidades en una misma vista sin etiqueta explícita.

## UX y producto

- Ajuste visible en Perfil: “Sistema de unidades” (`Métrico` / `Imperial`).
- Cambio debe aplicarse de forma inmediata o tras refresh controlado (definir comportamiento técnico).
- En campos de formulario con unidades, mostrar claramente la unidad activa.

## Entregables

- [ ] Modelo/preferencia de unidades por usuario en capa de dominio.
- [ ] UI de perfil para elegir sistema de unidades.
- [ ] Conversión y formateo en vistas/campos priorizados.
- [ ] Fallback para usuarios sin preferencia.
- [ ] Textos l10n (ES/EN) y revisión de copy.
- [ ] Pruebas manuales en web + iOS + Android.
- [ ] Documentación actualizada en `TASKS.md` y, si aplica, en docs de perfil/UX.

## Criterios de aceptación

- Usuario puede cambiar entre métrico e imperial desde perfil.
- La UI refleja el cambio en las superficies cubiertas por el MVP.
- Usuarios legacy (sin preferencia) siguen funcionando en métrico sin errores.
- No hay regresiones visibles entre plataformas.

## Riesgos / decisiones abiertas

- Definir lista exacta de pantallas/campos incluidos en Fase 1.
- Alinear redondeos para no generar discrepancias entre vistas.
- Revisar dependencia con futura expansión multi-idioma/unidades por región automática (fuera de alcance de esta tarea).
