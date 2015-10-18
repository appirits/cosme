require 'test_helper'

module Cosme
  class CosmeticTest < ActiveSupport::TestCase
    setup do
      @describe_class = Cosme::Cosmetic
    end

    teardown do
      Cosme.instance_variable_set(:@cosmetics, nil)
    end

    test '#initialize sets a cosmetic as @cosmetic' do
      cosmetic = {}
      cosme = Cosme::Cosmetic.new(cosmetic)
      assert_equal cosmetic, cosme.instance_variable_get(:@cosmetic)
    end

    test '#render sets :render options of the cosmetic' do
      cosmetic = {}
      options = 'OPTIONS'
      @describe_class.new(cosmetic).render(options)
      assert_equal cosmetic[:render], options
    end

    test '#render raises when @cosmetic is nil' do
      cosmetic = nil
      options = 'OPTIONS'
      assert_raises Cosme::CosmeticNotFound do
        @describe_class.new(cosmetic).render(options)
      end
    end
  end
end
