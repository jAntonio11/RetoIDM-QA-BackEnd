function fn() {
  var env = karate.env || 'qa';
  karate.log('Entorno de ejecucion:', env);

  var urls = {
    qa: 'https://serverest.dev',
    local: 'http://localhost:3000'
  };

  var config = {
    env: env,
    baseUrl: urls[env] || urls.qa
  };

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 20000);
  karate.configure('headers', { Accept: 'application/json' });

  return config;
}
