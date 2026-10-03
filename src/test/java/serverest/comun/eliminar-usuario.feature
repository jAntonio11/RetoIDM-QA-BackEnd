@ignore
Feature: Eliminar un usuario de prueba al finalizar el escenario

  Scenario: Eliminar usuario por identificador
    Given url baseUrl
    And path 'usuarios', id
    When method delete
