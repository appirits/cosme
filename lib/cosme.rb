require 'action_view'
require 'coffee-rails'

require 'cosme/version'
require 'cosme/helpers'
require 'cosme/middleware'
require 'cosme/engine'

module Cosme
  class << self
    def define(cosmetic)
      caller_path = caller_locations(1, 1)[0].path

      cosmetic[:render] = { file: default_file_path_for(caller_path) } unless cosmetic[:render]

      @cosmetics ||= {}
      @cosmetics[caller_path] = cosmetic
    end

    def default_file_path_for(caller_path)
      File.join(File.dirname(caller_path), File.basename(caller_path, '.*'))
    end

    def all
      return [] unless @cosmetics
      @cosmetics.values
    end

    def all_for(controller)
      return all if controller.blank?

      all.select do |option|
        routes = option[:routes]
        next true unless routes
        next false if routes[:controller].present? && controller.controller_path != routes[:controller].to_s
        next false if routes[:action].present? && controller.action_name != routes[:action].to_s
        true
      end
    end

    def disable_auto_cosmeticize!
      @disable_auto_cosmeticize = true
    end

    def auto_cosmeticize?
      @disable_auto_cosmeticize ? false : true
    end
  end
end
