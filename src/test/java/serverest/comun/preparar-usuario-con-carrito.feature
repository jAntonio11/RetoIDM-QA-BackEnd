@ignore
Feature: Preparar un usuario administrador que tenga un carrito registrado

  Scenario: Crear usuario, iniciar sesion, crear producto y registrar carrito
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature') { administrador: 'true' }

    Given url baseUrl
    And path 'login'
    And request { email: '#(usuario.datos.email)', password: '#(usuario.datos.password)' }
    When method post
    Then status 200
    * def token = response.authorization

    Given url baseUrl
    And path 'produtos'
    And header Authorization = token
    And request Datos.producto()
    When method post
    Then status 201
    * def idProducto = response._id

    Given url baseUrl
    And path 'carrinhos'
    And header Authorization = token
    And request { produtos: [ { idProduto: '#(idProducto)', quantidade: 1 } ] }
    When method post
    Then status 201
    * def idCarrinho = response._id
    * def idUsuario = usuario.id
