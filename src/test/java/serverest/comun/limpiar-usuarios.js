function() {
  var ids = karate.get('idsCreados') || [];
  karate.forEach(ids, function(id) {
    karate.call('classpath:serverest/comun/eliminar-usuario.feature', { id: id });
  });
}
