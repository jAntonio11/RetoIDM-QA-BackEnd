# Reto QA Backend – API de Usuarios ServeRest con Karate DSL

Suite de pruebas automatizadas para la API de Usuarios de [ServeRest](https://serverest.dev/) construida con **Karate DSL 1.5** y **JUnit 5**.

> Historia de usuario: *Como administrador del sistema, quiero poder gestionar los usuarios a través de la API, para administrar la base de datos de usuarios.*

## Stack

| Herramienta | Versión | Uso |
|---|---|---|
| Java (JDK) | 17+ | Ejecución |
| Maven | 3.8+ | Dependencias y ejecución |
| Karate DSL | 1.5.2 (`io.karatelabs`) | Pruebas de API, validación de esquemas y reportes |
| JUnit 5 | incluido en Karate | Runner |

## Estructura del proyecto

```text
qa-backend-karate/
├── pom.xml
├── README.md
├── docs/informe-estrategia.md        ← informe de estrategia y patrones
├── .github/workflows/pruebas-api.yml ← ejecución automática en GitHub Actions
└── src/test/java/
    ├── karate-config.js              ← configuración global (URL por entorno, timeouts)
    ├── logback-test.xml
    └── serverest/
        ├── ServeRestTest.java        ← runner de la suite completa (mvn test)
        ├── usuarios/
        │   ├── UsuariosRunner.java   ← runner para ejecutar desde el IDE
        │   ├── listar-usuarios.feature      GET    /usuarios
        │   ├── registrar-usuario.feature    POST   /usuarios
        │   ├── buscar-usuario.feature       GET    /usuarios/{_id}
        │   ├── actualizar-usuario.feature   PUT    /usuarios/{_id}
        │   ├── eliminar-usuario.feature     DELETE /usuarios/{_id}
        │   └── ciclo-vida-usuario.feature   flujo E2E completo
        ├── comun/                    ← pasos reutilizables (@ignore)
        │   ├── crear-usuario.feature
        │   ├── eliminar-usuario.feature
        │   ├── preparar-usuario-con-carrito.feature
        │   ├── liberar-carrito.feature
        │   └── limpiar-usuarios.js
        ├── datos/
        │   └── generador-datos.js    ← generador de datos de prueba únicos (JavaScript)
        └── esquemas/                 ← contratos JSON de las respuestas
            ├── usuario.json
            ├── respuesta-registro.json
            ├── respuesta-mensaje.json
            └── respuesta-usuario-con-carrito.json
```

## Requisitos previos

- JDK 17 o superior (`java -version`)
- Maven 3.8 o superior (`mvn -version`)
- Conexión a internet hacia `https://serverest.dev`

## Ejecución

```bash
# Suite completa
mvn clean test

# Solo pruebas de humo
mvn clean test -Dkarate.options="--tags @smoke"

# Solo casos negativos
mvn clean test -Dkarate.options="--tags @negativo"

# Un feature específico
mvn clean test -Dkarate.options="classpath:serverest/usuarios/registrar-usuario.feature"

# En paralelo (3 hilos)
mvn clean test -Dhilos=3

# Contra un ServeRest local (npx serverest)
mvn clean test -Dkarate.env=local
```

Desde el IDE: clic derecho sobre `UsuariosRunner.java` → *Run*, o sobre `ServeRestTest.java` para la suite completa.

### Tags disponibles

| Tag | Descripción |
|---|---|
| `@smoke` | Camino feliz de cada operación |
| `@positivo` / `@negativo` | Tipo de caso |
| `@contrato` | Escenarios que validan el esquema JSON completo |
| `@regla-negocio` | Reglas propias de ServeRest (PUT crea si no existe, no se elimina usuario con carrito) |
| `@e2e` | Ciclo de vida completo del usuario |
| `@listar` `@registrar` `@buscar` `@actualizar` `@eliminar` | Por endpoint |

## Reportes

Al terminar, Karate genera un reporte HTML con el detalle de cada petición y respuesta:

```
target/karate-reports/karate-summary.html
```

## Cobertura de criterios de aceptación

| # | Criterio | Feature | Escenarios |
|---|---|---|---|
| 1 | Obtener lista de todos los usuarios | `listar-usuarios.feature` | 4 positivos, 2 negativos |
| 2 | Registrar un usuario con datos válidos | `registrar-usuario.feature` | 2 positivos, 11 negativos |
| 3 | Buscar un usuario por ID | `buscar-usuario.feature` | 1 positivo, 4 negativos |
| 4 | Actualizar un usuario existente | `actualizar-usuario.feature` | 2 positivos, 4 negativos |
| 5 | Eliminar un usuario | `eliminar-usuario.feature` | 1 positivo, 2 negativos |
| – | Flujo integrado | `ciclo-vida-usuario.feature` | 1 E2E |

**Total: 34 escenarios** (contando cada fila de los *Scenario Outline*).

## Informe de estrategia

Ver [`docs/informe-estrategia.md`](docs/informe-estrategia.md).
