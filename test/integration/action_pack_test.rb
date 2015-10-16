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

    test 'can uses a url helper' do
      Cosme.define(render: { inline: '<%= root_path %>' })
      visit '/'
      assert page.has_selector? %(div[data-content="#{root_path}"])
    end

    test 'assigns a instance variable' do
      DummyController.class_eval do
        before_action { @variable_for_assign_test = 'variable_for_assign_test' }
      end
      Cosme.define(render: default_render_options)
      get '/'
      assert assigns(:variable_for_assign_test)
    end

    private

    def default_render_options
      { inline: '<h2>After Example</h2>' }
    end
  end
end
