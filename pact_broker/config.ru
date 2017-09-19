require 'fileutils'
require 'logger'
require 'sequel'
require 'pact_broker'
require 'delegate'

class DatabaseLogger < SimpleDelegator
  def info *args
    __getobj__().debug(*args)
  end
end

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Sequel::DATABASES.each { |db| db.disconnect }
    end
  end
end

logger = Logger.new(STDOUT)
logger.info("Database values")
#logger.debug(ENV['PACT_BROKER_DATABASE_USERNAME'])
logger.debug(ENV['DRP_EV_POSTGRESQL_URL'])

ENV['PACT_BROKER_DATABASE_USERNAME']=ENV['DRP_EV_POSTGRESQL_URL'].split(':')[1].split('/')[2]
ENV['PACT_BROKER_DATABASE_PASSWORD']=ENV['DRP_EV_POSTGRESQL_URL'].split('@')[0].split(':')[2]
ENV['PACT_BROKER_DATABASE_HOST']=ENV['DRP_EV_POSTGRESQL_URL'].split('@')[1].split(':')[0]
ENV['PACT_BROKER_DATABASE_NAME']=ENV['DRP_EV_POSTGRESQL_URL'].split('/')[3]

database_adapter = ENV.fetch('PACT_BROKER_DATABASE_ADAPTER','') != '' ? ENV['PACT_BROKER_DATABASE_ADAPTER'] : 'postgres'

DATABASE_CREDENTIALS = {
  adapter: database_adapter,
  user: ENV['PACT_BROKER_DATABASE_USERNAME'],
  password: ENV['PACT_BROKER_DATABASE_PASSWORD'],
  host: ENV['PACT_BROKER_DATABASE_HOST'],
  database: ENV['PACT_BROKER_DATABASE_NAME']
}

if ENV['PACT_BROKER_DATABASE_PORT'] =~ /^\d+$/
  DATABASE_CREDENTIALS[:port] = ENV['PACT_BROKER_DATABASE_PORT'].to_i
end

if ENV.fetch('PACT_BROKER_BASIC_AUTH_USERNAME','') != '' && ENV.fetch('PACT_BROKER_BASIC_AUTH_PASSWORD', '') != ''
  use Rack::Auth::Basic, "Restricted area" do |username, password|
    username == ENV['PACT_BROKER_BASIC_AUTH_USERNAME'] && password == ENV['PACT_BROKER_BASIC_AUTH_PASSWORD']
  end
end

app = PactBroker::App.new do | config |
  config.logger = ::Logger.new($stdout)
  config.logger.level = Logger::WARN
  config.database_connection = Sequel.connect(DATABASE_CREDENTIALS.merge(logger: DatabaseLogger.new(config.logger), encoding: 'utf8'))
  config.database_connection.timezone = :utc
end

run app
