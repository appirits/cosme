require 'test_helper'

class CosmeTest < Minitest::Test
  def teardown
    Cosme.instance_variable_set(:@cosmetics, nil)
  end

  def test_that_it_has_a_version_number
    refute_nil Cosme::VERSION
  end

  def test_define_method_that_it_sets_cosmetics
    Cosme.define(target: '.example', action: :before)
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_instance_of Hash, cosmetics
    refute_empty cosmetics
  end

  def test_default_file_path_for_method_that_it_returns_path_without_extension
    caller_path = 'path/to/file.rb'
    assert_equal Cosme.default_file_path_for(caller_path), 'path/to/file'
  end

  def test_all_method_that_it_returns_cosmetics_values
    Cosme.define(target: '.example', action: :before)
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all, cosmetics.values
  end
end
