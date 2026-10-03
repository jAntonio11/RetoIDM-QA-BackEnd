@ignore
Feature: Crear un usuario de prueba reutilizable

  Scenario: Registrar un usuario con datos generados
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def perfilAdministrador = karate.get('administrador', 'true')
    * def datos = Datos.usuario(perfilAdministrador)

    Given url baseUrl
    And path 'usuarios'
    And request datos
    When method post
    Then status 201
    * def id = response._id
