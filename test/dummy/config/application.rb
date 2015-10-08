ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)

# Pick the frameworks you want:
require 'action_controller/railtie'
require 'action_view/railtie'
#require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.secret_token = 'c08a6872a0206e0229fe61ee451a2f23'
    config.session_store :cookie_store, key: '_dummy_app_session'
    config.active_support.deprecation = :log
    config.eager_load = false
    config.root = File.expand_path('../../', __FILE__)

    # Show full error reports and disable caching.
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false
  end
end

Rails.backtrace_cleaner.remove_silencers!

Dummy::Application.initialize!

# Routes
Rails.application.routes.draw do
  root to: 'dummy#index'
end

# Controllers
class DummyController < ActionController::Base
  def index
    render inline: index_html_erb
  end

  private

  def layout
    <<-LAYOUT
      <html>
        <head>
          <title>Cosme</title>
        </head>
        <body>
          #{yield}
        </body>
      </html>
    LAYOUT
  end

  def index_html_erb
    layout do
      <<-ERB
        <div class="example">
          <h1>Example</h1>
        </div>
      ERB
    end
  end
end
