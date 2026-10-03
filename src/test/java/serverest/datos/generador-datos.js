function() {
  var LETRAS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var NOMBRES = ['Lucia', 'Mateo', 'Valeria', 'Santiago', 'Camila', 'Diego', 'Sofia', 'Andres', 'Daniela', 'Gabriel'];
  var APELLIDOS = ['Quispe', 'Flores', 'Rojas', 'Torres', 'Mendoza', 'Vargas', 'Castillo', 'Ramos', 'Chavez', 'Huaman'];
  var DOMINIO = 'qa-karate.com';

  function elegir(lista) {
    return lista[Math.floor(Math.random() * lista.length)];
  }

  function textoAleatorio(longitud) {
    var texto = '';
    for (var i = 0; i < longitud; i++) {
      texto += LETRAS.charAt(Math.floor(Math.random() * LETRAS.length));
    }
    return texto;
  }

  function codigoUnico() {
    return new Date().getTime() + '.' + java.util.UUID.randomUUID().toString().substring(0, 8);
  }

  var datos = {};

  datos.nombreCompleto = function() {
    return elegir(NOMBRES) + ' ' + elegir(APELLIDOS) + ' QA';
  };

  datos.correoUnico = function() {
    return 'qa.' + codigoUnico() + '@' + DOMINIO;
  };

  datos.contrasena = function() {
    return 'Qa#' + textoAleatorio(8);
  };

  // Identificador con el formato que exige la API (16 caracteres alfanumericos) pero que no existe
  datos.idInexistente = function() {
    return textoAleatorio(16);
  };

  datos.usuario = function(administrador) {
    return {
      nome: datos.nombreCompleto(),
      email: datos.correoUnico(),
      password: datos.contrasena(),
      administrador: administrador || 'true'
    };
  };

  datos.producto = function() {
    return {
      nome: 'Producto QA ' + codigoUnico(),
      preco: 100 + Math.floor(Math.random() * 900),
      descricao: 'Producto generado para pruebas automatizadas',
      quantidade: 10
    };
  };

  return datos;
}
