@usuarios @listar
Feature: Listar usuarios - GET /usuarios

  Como administrador del sistema
  Quiero obtener la lista de usuarios registrados
  Para conocer el estado de la base de datos de usuarios

  Background:
    * url baseUrl
    * def esquemaUsuario = read('classpath:serverest/esquemas/usuario.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke @positivo @contrato
  Scenario: Obtener la lista completa de usuarios con la estructura esperada
    Given path 'usuarios'
    When method get
    Then status 200
    And match response == { quantidade: '#number', usuarios: '#[] esquemaUsuario' }
    And match response.quantidade == karate.sizeOf(response.usuarios)

  @positivo
  Scenario: Encontrar en la lista a un usuario recien registrado usando su correo
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuario.id)

    Given path 'usuarios'
    And param email = usuario.datos.email
    When method get
    Then status 200
    And match response.quantidade == 1
    And match response.usuarios[0] == karate.merge(usuario.datos, { _id: usuario.id })

  @positivo
  Scenario: Listar solo a los usuarios que no son administradores
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature') { administrador: 'false' }
    * registrarParaLimpieza(usuario.id)

    Given path 'usuarios'
    And param administrador = 'false'
    When method get
    Then status 200
    And match each response.usuarios contains { administrador: 'false' }
    And match response.usuarios[*]._id contains usuario.id

  @positivo
  Scenario: Obtener una lista vacia cuando ningun usuario coincide con el filtro
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')

    Given path 'usuarios'
    And param email = Datos.correoUnico()
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negativo
  Scenario Outline: Rechazar la consulta cuando el filtro <filtro> tiene un valor no permitido
    Given path 'usuarios'
    And param <filtro> = '<valor>'
    When method get
    Then status 400
    And match response == { <filtro>: "<mensaje>" }

    Examples:
      | filtro        | valor             | mensaje                                  |
      | email         | correo-sin-arroba | email deve ser um email válido           |
      | administrador | si                | administrador deve ser 'true' ou 'false' |
