require 'webmock/rspec'
require 'json'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.order = :random
end