require 'bundler'
Bundler.require(:default, :test)

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.include Influxdb::Arel::RspecHelper

  config.around :each, time_freeze: ->(v){ v.is_a?(Date) || v.is_a?(Time) || v.is_a?(String) } do |example|
    datetime = if example.metadata[:time_freeze].is_a?(String)
      DateTime.parse(example.metadata[:time_freeze])
    else
      example.metadata[:time_freeze]
    end

    Timecop.freeze(datetime){ example.run }
  end
end
