@usuarios @e2e
Feature: Ciclo de vida completo de un usuario

  Como administrador del sistema
  Quiero gestionar un usuario de principio a fin
  Para asegurar que todas las operaciones funcionan de forma integrada

  Background:
    * url baseUrl
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def esquemaUsuario = read('classpath:serverest/esquemas/usuario.json')
    * def esquemaRegistro = read('classpath:serverest/esquemas/respuesta-registro.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke
  Scenario: Registrar, consultar, listar, actualizar y eliminar un usuario
    * def usuarioOriginal = Datos.usuario()
    * def usuarioModificado = Datos.usuario('false')

    # Registrar
    Given path 'usuarios'
    And request usuarioOriginal
    When method post
    Then status 201
    And match response == esquemaRegistro
    * def idUsuario = response._id
    * registrarParaLimpieza(idUsuario)

    # Consultar por ID
    Given path 'usuarios', idUsuario
    When method get
    Then status 200
    And match response == esquemaUsuario
    And match response == karate.merge(usuarioOriginal, { _id: idUsuario })

    # Ubicar en la lista
    Given path 'usuarios'
    And param _id = idUsuario
    When method get
    Then status 200
    And match response.quantidade == 1

    # Actualizar
    Given path 'usuarios', idUsuario
    And request usuarioModificado
    When method put
    Then status 200
    And match response.message == 'Registro alterado com sucesso'

    Given path 'usuarios', idUsuario
    When method get
    Then status 200
    And match response == karate.merge(usuarioModificado, { _id: idUsuario })

    # Eliminar
    Given path 'usuarios', idUsuario
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    Given path 'usuarios', idUsuario
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'
