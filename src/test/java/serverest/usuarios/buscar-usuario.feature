@usuarios @buscar
Feature: Buscar usuario por ID - GET /usuarios/{_id}

  Como administrador del sistema
  Quiero consultar un usuario especifico por su identificador
  Para revisar su informacion registrada

  Background:
    * url baseUrl
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def esquemaUsuario = read('classpath:serverest/esquemas/usuario.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke @positivo @contrato
  Scenario: Obtener la informacion de un usuario existente por su ID
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuario.id)

    Given path 'usuarios', usuario.id
    When method get
    Then status 200
    And match response == esquemaUsuario
    And match response == karate.merge(usuario.datos, { _id: usuario.id })

  @negativo
  Scenario: Informar que el usuario no existe cuando el ID es valido pero no esta registrado
    Given path 'usuarios', Datos.idInexistente()
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @negativo
  Scenario Outline: Rechazar la busqueda cuando el ID no tiene el formato esperado: <caso>
    Given path 'usuarios', '<id>'
    When method get
    Then status 400
    And match response == { id: 'id deve ter exatamente 16 caracteres alfanuméricos' }

    Examples:
      | caso                   | id                |
      | menos de 16 caracteres | abc123            |
      | mas de 16 caracteres   | abcdefghij1234567 |
      | contiene simbolos      | abcd-efgh_ijkl.m  |
