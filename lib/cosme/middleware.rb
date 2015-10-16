module Cosme
  class Middleware
    include ActionView::Helpers::TagHelper
    include Cosme::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env

      response = @app.call(env)
      return response unless Cosme.auto_cosmeticize?

      html = response_to_html(response)
      return response unless html

      new_html = insert_cosmeticize_tag(html)
      new_response(response, new_html)
    end

    private

    def response_to_html(response)
      status, headers, body = response
      return if status != 200
      return unless html_headers? headers
      take_html(body)
    end

    def insert_cosmeticize_tag(html)
      cosmeticizer = cosmeticize(controller)
      html.sub(/<body[^>]*>/) { [$~, cosmeticizer].join }
    end

    def new_response(response, new_html)
      status, headers, _ = response
      headers['Content-Length'] = new_html.bytesize.to_s
      [status, headers, [new_html]]
    end

    def html_headers?(headers)
      return false unless headers['Content-Type']
      return false unless headers['Content-Type'].include? 'text/html'
      return false if headers['Content-Transfer-Encoding'] == 'binary'
      true
    end

    # body is one of the following:
    #   - Array
    #   - ActionDispatch::Response
    #   - ActionDispatch::Response::RackBody
    def take_html(body)
      strings = []
      body.each { |buf| strings << buf }
      strings.join
    end

    # Use in Cosme::Helpers#cosmeticize
    def render(options = {})
      view_context = ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
      view_context.render(options)
    end

    def controller
      @env['action_controller.instance']
    end

    def assigns
      return {} unless controller
      controller.view_context.assigns
    end

    def controller
      return unless @env
      @env['action_controller.instance']
    end
  end
end
