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

      all.select do |cosmetic|
        routes_match?(controller, cosmetic[:routes])
      end
    end

    def disable_auto_cosmeticize!
      @disable_auto_cosmeticize = true
    end

    def auto_cosmeticize?
      @disable_auto_cosmeticize ? false : true
    end

    private

    def routes_match?(controller, routes)
      return true unless routes
      return false unless routes_match_action?(controller, routes)
      return false unless routes_match_controller?(controller, routes)
      true
    end

    def routes_match_action?(controller, routes)
      return true unless routes[:action]
      if routes[:action].is_a? Array
        routes[:action].map(&:to_s).include? controller.action_name
      else
        controller.action_name == routes[:action].to_s
      end
    end

    def routes_match_controller?(controller, routes)
      return true unless routes[:controller]
      if routes[:controller].is_a? Array
        routes[:controller].map(&:to_s).include? controller.controller_path
      else
        controller.controller_path == routes[:controller].to_s
      end
    end
  end
end
