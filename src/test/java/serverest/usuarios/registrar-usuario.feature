@usuarios @registrar
Feature: Registrar usuarios - POST /usuarios

  Como administrador del sistema
  Quiero registrar nuevos usuarios
  Para que puedan acceder a la tienda

  Background:
    * url baseUrl
    * def Datos = call read('classpath:serverest/datos/generador-datos.js')
    * def esquemaRegistro = read('classpath:serverest/esquemas/respuesta-registro.json')
    * def idsCreados = []
    * def registrarParaLimpieza = function(id) { karate.appendTo('idsCreados', id) }
    * configure afterScenario = read('classpath:serverest/comun/limpiar-usuarios.js')

  @smoke @positivo @contrato
  Scenario Outline: Registrar un usuario con datos validos y perfil administrador "<administrador>"
    * def nuevoUsuario = Datos.usuario('<administrador>')

    Given path 'usuarios'
    And request nuevoUsuario
    When method post
    Then status 201
    And match response == esquemaRegistro
    And match response.message == 'Cadastro realizado com sucesso'
    * registrarParaLimpieza(response._id)
    * def idRegistrado = response._id

    Given path 'usuarios', idRegistrado
    When method get
    Then status 200
    And match response == karate.merge(nuevoUsuario, { _id: idRegistrado })

    Examples:
      | administrador |
      | true          |
      | false         |

  @negativo
  Scenario: Rechazar el registro cuando el correo ya pertenece a otro usuario
    * def usuarioExistente = call read('classpath:serverest/comun/crear-usuario.feature')
    * registrarParaLimpieza(usuarioExistente.id)
    * def nuevoUsuario = Datos.usuario()
    * set nuevoUsuario.email = usuarioExistente.datos.email

    Given path 'usuarios'
    And request nuevoUsuario
    When method post
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

  @negativo
  Scenario Outline: Rechazar el registro cuando falta el campo obligatorio "<campo>"
    * def nuevoUsuario = Datos.usuario()
    * remove nuevoUsuario.<campo>

    Given path 'usuarios'
    And request nuevoUsuario
    When method post
    Then status 400
    And match response == { <campo>: '<campo> é obrigatório' }

    Examples:
      | campo         |
      | nome          |
      | email         |
      | password      |
      | administrador |

  @negativo
  Scenario Outline: Rechazar el registro cuando <caso>
    * def nuevoUsuario = Datos.usuario()
    * set nuevoUsuario.<campo> = <valor>

    Given path 'usuarios'
    And request nuevoUsuario
    When method post
    Then status 400
    And match response == { <campo>: "<mensaje>" }

    Examples:
      | caso                                 | campo         | valor               | mensaje                                  |
      | el nombre esta vacio                 | nome          | ''                  | nome não pode ficar em branco            |
      | el nombre no es un texto             | nome          | 12345               | nome deve ser uma string                 |
      | el correo no tiene un formato valido | email         | 'correo.sin.arroba' | email deve ser um email válido           |
      | la contrasena esta vacia             | password      | ''                  | password não pode ficar em branco        |
      | el perfil administrador no es valido | administrador | 'si'                | administrador deve ser 'true' ou 'false' |

  @negativo
  Scenario: Rechazar el registro cuando se envia un campo que la API no admite
    * def nuevoUsuario = Datos.usuario()
    * set nuevoUsuario.telefono = '987654321'

    Given path 'usuarios'
    And request nuevoUsuario
    When method post
    Then status 400
    And match response == { telefono: 'telefono não é permitido' }
