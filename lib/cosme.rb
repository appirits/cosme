require 'action_view'
require 'coffee-rails'

require "cosme/version"

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

  module Helpers
    def cosmeticize
      Cosme.all.map do |cosmetic|
        content = cosmetic[:render] ? render(cosmetic[:render]) : render
        content_tag(:div, nil, class: 'cosmetic', data: cosmetic.except(:render).merge(content: content))
      end.join.html_safe
    end
  end

  class Engine < ::Rails::Engine
    config.to_prepare do
      Dir.glob(Rails.root.join('app/cosmetics/**/*.rb')).each do |c|
        require_dependency(c)
      end
    end

    ActiveSupport.on_load(:action_view) do
      ActionView::Base.send(:include, Cosme::Helpers)
    end
  end
end
