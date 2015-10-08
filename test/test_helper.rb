ENV['RAILS_ENV'] ||= 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require File.expand_path('../dummy/config/application', __FILE__)
require 'minitest/autorun'
require 'capybara'

Capybara.app = Dummy::Application

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end
