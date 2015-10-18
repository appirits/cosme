module Cosme
  class CosmeticNotFound < StandardError; end

  class Cosmetic
    def initialize(cosmetic)
      @cosmetic = cosmetic
    end

    def render(options)
      raise Cosme::CosmeticNotFound, 'Cosmetic is not found. Please call `Cosme#define` method first.' unless @cosmetic
      @cosmetic[:render] = options
    end
  end
end
