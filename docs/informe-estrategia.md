# Informe de estrategia de automatización – API Usuarios ServeRest

## 1. Objetivo y alcance

Validar de forma automatizada las cinco operaciones de la API de Usuarios de ServeRest (listar, registrar, buscar por ID, actualizar y eliminar), cubriendo casos positivos, negativos, validación de contrato JSON y reglas de negocio propias de la API.

Fuera de alcance: pruebas de carga, seguridad y los módulos de productos, login y carritos (solo se usan como preparación de datos en un escenario de regla de negocio).

## 2. Enfoque

| Pilar | Cómo se aplica |
|---|---|
| **Un feature por endpoint** | Cada operación tiene su propio archivo con la historia de usuario en su cabecera; facilita la trazabilidad con los criterios de aceptación. |
| **Pruebas independientes** | Cada escenario crea sus propios datos, no depende del orden de ejecución y puede correr en paralelo. |
| **Datos únicos en cada ejecución** | `generador-datos.js` (JavaScript nativo de Karate) crea nombres, correos y contraseñas únicos (marca de tiempo + UUID). Evita choques con datos de otros usuarios en el entorno público compartido. |
| **Limpieza automática** | Cada usuario creado se registra con `registrarParaLimpieza(...)` y se elimina al final del escenario (`afterScenario`), aunque la prueba falle. El entorno queda como estaba. |
| **Validación de contrato** | Esquemas JSON en `esquemas/` con *fuzzy matchers* de Karate (`#string`, `#number`, `#regex`). Se usa `match ==` (coincidencia exacta) para detectar también campos de más. |
| **Validación de valores** | Además del contrato, se compara el contenido real: lo que se registra/actualiza es exactamente lo que la API devuelve después (`karate.merge(datos, { _id })`). |
| **Pruebas basadas en datos** | `Scenario Outline` para validaciones de campos (obligatorios, vacíos, formato, tipo), evitando duplicar escenarios. |
| **Reutilización** | Pasos comunes en `comun/` (crear usuario, preparar carrito, limpiar) marcados con `@ignore` para que no se ejecuten solos. |
| **Configuración por entorno** | `karate-config.js` permite cambiar de entorno con `-Dkarate.env` (público o ServeRest local). |

## 3. Patrones utilizados

- **BDD con Gherkin**: escenarios con nombres en lenguaje de negocio y estructura *Given / When / Then*.
- **Data Builder / Test Data Generator**: `generador-datos.js` centraliza la creación de datos válidos; cada escenario solo modifica el campo que quiere probar (`set` / `remove`).
- **Reusable Steps (llamadas a features)**: los pasos de preparación y limpieza se invocan con `call read(...)`.
- **Contract Testing ligero**: esquemas JSON versionados junto al código.
- **Setup / Teardown por escenario**: creación al inicio y limpieza en `afterScenario`.

## 4. Diseño de casos

Técnicas aplicadas: partición de equivalencias (valores válidos / inválidos por campo), valores límite (ID con menos de 16 caracteres, con 17 y con 16 pero con símbolos) y pruebas de reglas de negocio.

| Operación | Positivos | Negativos |
|---|---|---|
| GET /usuarios | lista completa + contrato, filtro por correo, filtro por perfil, filtro sin resultados | correo con formato inválido, perfil no permitido |
| POST /usuarios | registro como administrador y no administrador + verificación posterior | correo duplicado, 4 campos obligatorios, 5 valores inválidos, campo no admitido |
| GET /usuarios/{_id} | consulta por ID + contrato + valores | ID inexistente, 3 formatos de ID inválidos |
| PUT /usuarios/{_id} | actualización completa + verificación, **PUT a ID inexistente crea usuario (201)** | correo de otro usuario, 3 valores inválidos |
| DELETE /usuarios/{_id} | eliminación + verificación | ID inexistente, **usuario con carrito no se puede eliminar** |
| E2E | registrar → consultar → listar → actualizar → eliminar → confirmar | – |

## 5. Hallazgos durante el análisis de la API

1. **GET /usuarios/{_id} exige un ID de exactamente 16 caracteres alfanuméricos.** Con otro formato responde `400 {"id": "id deve ter exatamente 16 caracteres alfanuméricos"}` y no `Usuário não encontrado`. Por eso el generador crea IDs inexistentes con el formato correcto.
2. **DELETE y PUT no validan el formato del ID**, a diferencia de GET (comportamiento inconsistente entre endpoints; se documenta como observación).
3. **PUT funciona como "crear o actualizar"**: si el ID no existe registra un usuario nuevo con otro `_id` y responde `201`.
4. **DELETE de un usuario inexistente responde `200`** con `Nenhum registro excluído` (no `404`).
5. **Los filtros de GET /usuarios buscan coincidencias parciales** (internamente usan expresiones regulares). Por eso las pruebas usan valores únicos para filtrar.
6. Todos los mensajes de la API están en portugués; las aserciones usan el texto exacto.

## 6. Ejecución continua

El workflow `.github/workflows/pruebas-api.yml` ejecuta la suite en cada *push* o *pull request* a `main` y publica el reporte HTML de Karate como artefacto descargable.

## 7. Mejoras propuestas

- Validación con JSON Schema formal (draft-07) si el equipo ya mantiene contratos OpenAPI.
- Pruebas de rendimiento reutilizando los mismos features con **Karate Gatling**.
- Integración del reporte con Allure o Xray para trazabilidad con Jira.
- Pruebas de seguridad básicas (inyección en filtros, campos muy largos).
