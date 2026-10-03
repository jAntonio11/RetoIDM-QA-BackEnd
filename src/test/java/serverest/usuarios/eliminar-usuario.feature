@usuarios @eliminar
Feature: Eliminar usuario - DELETE /usuarios/{_id}

  Como administrador del sistema
  Quiero eliminar usuarios
  Para mantener depurada la base de datos de usuarios

  Background:
    * url baseUrl
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def esquemaMensaje = read('classpath:serverest/esquemas/respuesta-mensaje.json')
    * def esquemaUsuarioConCarrito = read('classpath:serverest/esquemas/respuesta-usuario-con-carrito.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke @positivo @contrato
  Scenario: Eliminar un usuario existente y confirmar que ya no se encuentra
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuario.id)

    Given path 'usuarios', usuario.id
    When method delete
    Then status 200
    And match response == esquemaMensaje
    And match response.message == 'Registro excluído com sucesso'

    Given path 'usuarios', usuario.id
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @negativo
  Scenario: Informar que no se elimino ningun registro cuando el usuario no existe
    Given path 'usuarios', Datos.idInexistente()
    When method delete
    Then status 200
    And match response == { message: 'Nenhum registro excluído' }

  @negativo @regla-negocio
  Scenario: Impedir la eliminacion de un usuario que tiene un carrito registrado
    * def preparacion = call read('classpath:serverest/comun/preparar-usuario-con-carrito.feature')
    * registrarParaLimpieza(preparacion.idUsuario)

    Given path 'usuarios', preparacion.idUsuario
    When method delete
    Then status 400
    And match response == esquemaUsuarioConCarrito
    And match response.message == 'Não é permitido excluir usuário com carrinho cadastrado'
    And match response.idCarrinho == preparacion.idCarrinho

    * call read('classpath:serverest/comun/liberar-carrito.feature') { token: '#(preparacion.token)', idProducto: '#(preparacion.idProducto)' }
