module Cosme
  module Helpers
    def cosmeticize(controller = nil)
      Cosme.all_for(controller).map do |cosmetic|
        content = cosmetic[:render] ? render(cosmetic[:render]) : render
        content_tag(:div, nil, class: 'cosmetic', data: cosmetic.except(:render).merge(content: "#{content}"))
      end.join.html_safe
    end
  end
end
