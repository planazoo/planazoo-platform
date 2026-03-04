# Configurar Amadeus para número de vuelo (T246)

La funcionalidad **“Obtener datos del vuelo”** en eventos de tipo Desplazamiento / Avión usa la API **Amadeus On-Demand Flight Status**. Las credenciales se configuran en el backend (Cloud Functions) para no exponerlas en la app.

## 1. Cuenta Amadeus for Developers

1. Regístrate en [developers.amadeus.com](https://developers.amadeus.com/).
2. En **My Self-Service Workspace** crea una aplicación.
3. Anota el **API Key** (client_id) y el **API Secret** (client_secret).

Por defecto tendrás acceso al **entorno test** (cuota gratuita mensual). Para producción mantienes la misma cuota gratis y pagas solo por uso extra (pay-as-you-go).

## 2. Configuración en Cloud Functions

Configura las variables en Firebase:

```bash
firebase functions:config:set amadeus.client_id="TU_CLIENT_ID" amadeus.client_secret="TU_CLIENT_SECRET"
```

Opcional — usar entorno de producción de Amadeus (datos en tiempo real):

```bash
firebase functions:config:set amadeus.base="https://api.amadeus.com"
```

Por defecto se usa `https://test.api.amadeus.com` (datos de prueba).

Despliega las funciones:

```bash
cd functions && npm run deploy
```

## 3. Uso en la app

1. Crear o editar un **evento**.
2. Elegir tipo **Desplazamiento** y subtipo **Avión**.
3. Escribir el **número de vuelo** en formato IATA (ej. `IB6842`, `AF1135`).
4. Pulsar **“Obtener datos del vuelo”**.
5. La descripción, fecha, hora y duración se rellenan con los datos del vuelo; se guardan también en `extraData` (flightNumber, originIata, destinationIata, etc.).

## 4. Errores frecuentes

- **“Amadeus API no configurada”**: Falta `amadeus.client_id` o `amadeus.client_secret` en la config de Functions.
- **“Formato de número de vuelo no válido”**: Usar código IATA completo (2 letras/código + número), ej. `IB6842`.
- **“No se encontraron datos para este vuelo y fecha”**: En entorno test solo hay datos limitados; probar con otra fecha o pasar a producción.

## 5. Referencias

- [Amadeus On-Demand Flight Status](https://developers.amadeus.com/self-service/category/flights/api-doc/on-demand-flight-status)
- [Amadeus Pricing](https://developers.amadeus.com/pricing)
- T246: `docs/tareas/T246_DESPLAZAMIENTO_POR_NUMERO_VUELO_TREN.md`
