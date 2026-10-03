@ignore
Feature: Cancelar el carrito y eliminar el producto creados para la prueba

  Scenario: Cancelar compra y eliminar producto
    Given url baseUrl
    And path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    Then status 200

    Given url baseUrl
    And path 'produtos', idProducto
    And header Authorization = token
    When method delete
    Then status 200
