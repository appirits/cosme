require 'test_helper'

class CosmeTest < ActiveSupport::TestCase
  teardown do
    Cosme.instance_variable_set(:@cosmetics, nil)
    Cosme.instance_variable_set(:@disable_auto_cosmeticize, nil)
  end

  test 'has a version number' do
    refute_nil Cosme::VERSION
  end

  test '.define sets Hash as @cosmetics' do
    Cosme.define(target: '.example', action: :before)
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_instance_of Hash, cosmetics
    refute_empty cosmetics
  end

  test '.default_file_path_for returns a path without extension' do
    caller_path = 'path/to/file.rb'
    assert_equal Cosme.default_file_path_for(caller_path), 'path/to/file'
  end

  test '.all returns the values of @cosmetics' do
    Cosme.define(target: '.example', action: :before)
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all, cosmetics.values
  end

  test '.all_for returns the values of @cosmetics when match controller and action' do
    Cosme.define(routes: { controller: :dummy, action: :index })
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all_for(dummy_controller), cosmetics.values
  end

  test '.all_for returns the values of @cosmetics when match controller' do
    Cosme.define(routes: { controller: :dummy })
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all_for(dummy_controller), cosmetics.values
  end

  test '.all_for returns the values of @cosmetics when match the one of controllers' do
    Cosme.define(routes: { controller: [:dummy, :foo, :bar] })
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all_for(dummy_controller), cosmetics.values
  end

  test '.all_for returns the values of @cosmetics when match action' do
    Cosme.define(routes: { action: :index })
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all_for(dummy_controller), cosmetics.values
  end

  test '.all_for returns the values of @cosmetics when match the one of actions' do
    Cosme.define(routes: { action: [:index, :show] })
    cosmetics = Cosme.instance_variable_get(:@cosmetics)
    assert_equal Cosme.all_for(dummy_controller), cosmetics.values
  end

  test '.all_for returns a empty array when do not match controller' do
    Cosme.define(routes: { controller: :users, action: :index })
    assert_empty Cosme.all_for(dummy_controller)
  end

  test '.all_for returns a empty array when do not match action' do
    Cosme.define(routes: { controller: :dummy, action: :show })
    assert_empty Cosme.all_for(dummy_controller)
  end

  test '.disable_auto_cosmeticize! sets @disable_auto_cosmeticize' do
    Cosme.disable_auto_cosmeticize!
    assert Cosme.instance_variable_get(:@disable_auto_cosmeticize)
  end

  test '.auto_cosmeticize? returns false when @disable_auto_cosmeticize is true' do
    Cosme.disable_auto_cosmeticize!
    refute Cosme.auto_cosmeticize?
  end

  test '.auto_cosmeticize? returns true when @disable_auto_cosmeticize is false' do
    assert Cosme.auto_cosmeticize?
  end

  private

  def dummy_controller
    @dummy_controller ||= build_dummy_controller
  end

  def build_dummy_controller
    mock = MiniTest::Mock.new
    mock.expect(:blank?, false)
    mock.expect(:controller_path, 'dummy')
    mock.expect(:action_name, 'index')
    mock
  end
end
