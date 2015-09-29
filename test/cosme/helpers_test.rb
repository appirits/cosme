require 'test_helper'

module Cosme
  class HelpersTest < Minitest::Test
    def teardown
      Cosme.instance_variable_set(:@cosmetics, nil)
    end

    def test_that_it_has_cosmeticize_method
      assert ActionView::Base.new.respond_to?(:cosmeticize)
    end

    def test_cosmeticize_method_that_it_returns_safe_buffer
      assert_instance_of ActiveSupport::SafeBuffer, ActionView::Base.new.cosmeticize
    end

    def test_cosmeticize_method_that_it_returns_escaped_html_in_data_content
      html = '<span class="before-example">Before Example</span>'
      Cosme.define(target: '.example', action: :before, render: { inline: html })
      assert_match /data-content="#{ERB::Util.html_escape(html)}"/, ActionView::Base.new.cosmeticize
    end
  end
end
