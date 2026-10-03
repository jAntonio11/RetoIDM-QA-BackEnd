@usuarios @actualizar
Feature: Actualizar usuario - PUT /usuarios/{_id}

  Como administrador del sistema
  Quiero actualizar la informacion de un usuario existente
  Para mantener sus datos al dia

  Background:
    * url baseUrl
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def esquemaMensaje = read('classpath:serverest/esquemas/respuesta-mensaje.json')
    * def esquemaRegistro = read('classpath:serverest/esquemas/respuesta-registro.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke @positivo @contrato
  Scenario: Actualizar todos los datos de un usuario existente
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuario.id)
    * def datosActualizados = Datos.usuario('false')

    Given path 'usuarios', usuario.id
    And request datosActualizados
    When method put
    Then status 200
    And match response == esquemaMensaje
    And match response.message == 'Registro alterado com sucesso'

    Given path 'usuarios', usuario.id
    When method get
    Then status 200
    And match response == karate.merge(datosActualizados, { _id: usuario.id })

  @positivo @regla-negocio
  Scenario: Registrar un usuario nuevo cuando se actualiza un ID que no existe
    * def nuevoUsuario = Datos.usuario()

    Given path 'usuarios', Datos.idInexistente()
    And request nuevoUsuario
    When method put
    Then status 201
    And match response == esquemaRegistro
    And match response.message == 'Cadastro realizado com sucesso'
    * registrarParaLimpieza(response._id)
    * def idCreado = response._id

    Given path 'usuarios', idCreado
    When method get
    Then status 200
    And match response.email == nuevoUsuario.email

  @negativo
  Scenario: Rechazar la actualizacion cuando el correo pertenece a otro usuario
    * def usuarioA = call read('classpath:serverest/comun/crear-usuario.feature')
    * def usuarioB = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuarioA.id)
    * registrarParaLimpieza(usuarioB.id)
    * def datosActualizados = Datos.usuario()
    * set datosActualizados.email = usuarioB.datos.email

    Given path 'usuarios', usuarioA.id
    And request datosActualizados
    When method put
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

  @negativo
  Scenario Outline: Rechazar la actualizacion cuando <caso>
    * def usuario = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuario.id)
    * def datosActualizados = Datos.usuario()
    * set datosActualizados.<campo> = <valor>

    Given path 'usuarios', usuario.id
    And request datosActualizados
    When method put
    Then status 400
    And match response == { <campo>: "<mensaje>" }

    Examples:
      | caso                                 | campo         | valor   | mensaje                                  |
      | el correo no tiene un formato valido | email         | 'qa@'   | email deve ser um email válido           |
      | el nombre esta vacio                 | nome          | ''      | nome não pode ficar em branco            |
      | el perfil administrador no es valido | administrador | 'admin' | administrador deve ser 'true' ou 'false' |
