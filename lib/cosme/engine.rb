module Cosme
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
