require 'test_helper'

module Cosme
  class HelpersTest < ActiveSupport::TestCase
    teardown do
      Cosme.instance_variable_set(:@cosmetics, nil)
    end

    test 'ActionView::Base has #cosmeticize' do
      assert ActionView::Base.new.respond_to?(:cosmeticize)
    end

    test '#cosmeticize returns safe_buffer' do
      assert_instance_of ActiveSupport::SafeBuffer, ActionView::Base.new.cosmeticize
    end

    test '#cosmeticize returns the escaped html in data-content' do
      html = '<span class="before-example">Before Example</span>'
      Cosme.define(target: '.example', action: :before, render: { inline: html })
      assert_match /data-content="#{ERB::Util.html_escape(html)}"/, ActionView::Base.new.cosmeticize
    end
  end
end
