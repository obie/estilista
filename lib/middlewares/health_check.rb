class HealthCheck
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] == '/health-check'
      return [200, {}, ['healthy']]
    end
    @app.call(env)
  end
end