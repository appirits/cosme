require 'action_view'
require 'coffee-rails'

require 'cosme/version'
require 'cosme/helpers'
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
  end
end
