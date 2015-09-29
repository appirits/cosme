require 'action_view'
require 'coffee-rails'

require 'cosme/version'
require 'cosme/helpers'
require 'cosme/engine'

module Cosme
  class << self
    def define(cosmetic)
      caller_path = caller_locations(1, 1)[0].path

      render_options = cosmetic[:render] || {}
      render_options[:file] ||= default_file_path_for(caller_path) if render_options
      cosmetic[:render] = render_options

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
  end
end
