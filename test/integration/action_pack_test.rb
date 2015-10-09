require 'test_helper'

module Cosme
  class ActionPackTest < ActionDispatch::IntegrationTest
    teardown do
      Cosme.instance_variable_set(:@cosmetics, nil)
      Cosme.instance_variable_set(:@disable_auto_cosmeticize, nil)
    end

    test 'includes the additional element with "cosmetic" class' do
      Cosme.define(render: default_render_options)
      visit '/'
      assert page.has_selector? 'div[class="cosmetic"]'
    end

    test 'includes the additional element with data-target' do
      target = '.example'
      Cosme.define(render: default_render_options, target: target)
      visit '/'
      assert page.has_selector? %(div[data-target="#{target}"])
    end

    test 'includes the additional element with data-action' do
      action = :before
      Cosme.define(render: default_render_options, action: action)
      visit '/'
      assert page.has_selector? %(div[data-action="#{action}"])
    end

    test 'does not include the additional element when Cosme#auto_cosmeticize? is false' do
      Cosme.disable_auto_cosmeticize!
      Cosme.define(render: default_render_options)
      visit '/'
      refute page.has_selector? 'div[class="cosmetic"]'
    end

    private

    def default_render_options
      { inline: '<h2>After Example</h2>' }
    end
  end
end
