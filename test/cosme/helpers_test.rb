require 'test_helper'

module Cosme
  class HelpersTest < Minitest::Test
    def test_that_it_has_cosmeticize_method
      assert ActionView::Base.new.respond_to?(:cosmeticize)
    end

    def test_cosmeticize_method_that_it_returns_safe_buffer
      assert_instance_of ActiveSupport::SafeBuffer, ActionView::Base.new.cosmeticize
    end
  end
end
