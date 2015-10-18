require 'test_helper'

module Cosme
  class MiddlewareTest < ActiveSupport::TestCase
    setup do
      @subject = Cosme::Middleware.new(app)
    end

    teardown do
      Cosme.instance_variable_set(:@cosmetics, nil)
    end

    test '#initialize sets @app' do
      app = 'APP'
      @subject = Cosme::Middleware.new(app)
      assert_equal @subject.instance_variable_get(:@app), app
    end

    test '#call does nothing when disable auto cosmeticize' do
      response = 'RESPONSE'
      app = @subject.instance_variable_get(:@app)
      app.stub(:call, response) do
        Cosme.stub(:auto_cosmeticize?, false) do
          env = {}
          assert_equal @subject.call(env), response
        end
      end
    end

    test '#call does nothing when the response is not html' do
      response = 'RESPONSE'
      app = @subject.instance_variable_get(:@app)
      app.stub(:call, response) do
        @subject.stub(:response_to_html, nil) do
          env = {}
          assert_equal @subject.call(env), response
        end
      end
    end

    test '#call returns a new response' do
      response = 'RESPONSE'
      app = @subject.instance_variable_get(:@app)
      app.stub(:call, response) do
        html = '<h1>Example</h1>'
        @subject.stub(:response_to_html, html) do
          new_response = 'NEW RESPONSE'
          @subject.stub(:new_response, new_response) do
            env = {}
            assert_equal @subject.call(env), new_response
          end
        end
      end
    end

    test '#response_to_html returns nil when status is not 200' do
      response = build_response(status: 404)
      @subject.stub(:html_headers?, true) do
        @subject.stub(:take_html, '<h1>Example</h1>') do
          assert_nil @subject.send(:response_to_html, response)
        end
      end
    end

    test '#response_to_html returns nil when headers are not html headers' do
      response = build_response(status: 200)
      @subject.stub(:html_headers?, false) do
        @subject.stub(:take_html, '<h1>Example</h1>') do
          assert_nil @subject.send(:response_to_html, response)
        end
      end
    end

    test '#response_to_html returns HTML String' do
      html = '<h1>Example</h1>'
      response = build_response(status: 200)
      @subject.stub(:html_headers?, true) do
        @subject.stub(:take_html, html) do
          assert_equal @subject.send(:response_to_html, response), html
        end
      end
    end

    test '#insert_cosmeticize_tag inserts the HTML element to cosmeticize' do
      html = '<body>Example</body>'
      cosmeticize_tag = '<div class="cosmetics" />'
      @subject.stub(:cosmeticize, cosmeticize_tag) do
        assert_match /#{cosmeticize_tag}/, @subject.send(:insert_cosmeticize_tag, html)
      end
    end

    test '#insert_cosme_js inserts the script tag' do
      script_tag = '<script />'

      view_context = MiniTest::Mock.new
      view_context.expect(:javascript_include_tag, script_tag, ['cosme', Hash])

      controller = MiniTest::Mock.new
      controller.expect(:try, view_context, [:view_context])

      @subject.stub(:controller, controller) do
        html = '<head><title>Example</title></head>'
        assert_match /#{script_tag}/, @subject.send(:insert_cosme_js, html)
      end
    end

    test '#insert_cosme_js returns the original HTML when controller is nil' do
      @subject.stub(:controller, nil) do
        html = '<head><title>Example</title></head>'
        assert_equal html, @subject.send(:insert_cosme_js, html)
      end
    end

    test '#new_response builds a response with a new body' do
      html = '<h1>Example</h1>'
      response = build_response(body: [html])

      new_html = [html, '<h2>After Example</h2>'].join
      _, _, body = @subject.send(:new_response, response, new_html)

      assert_equal body[0], new_html
    end

    test '#new_response builds a response with a new Content-Length' do
      html = '<h1>Example</h1>'
      response = build_response(body: [html])

      _, headers, _ = response
      content_length = headers['Content-Length']

      new_html = [html, '<h2>After Example</h2>'].join
      _, new_response_headers, _ = @subject.send(:new_response, response, new_html)

      assert_instance_of String, new_response_headers['Content-Length']
      refute_equal new_response_headers['Content-Length'], content_length
    end

    test '#html_headers? returns true when Content-Type is text/html' do
      headers = { 'Content-Type' => 'text/html' }
      assert @subject.send(:html_headers?, headers)
    end

    test '#html_headers? returns false when Content-Type is not text/html' do
      headers = { 'Content-Type' => 'text/plain' }
      refute @subject.send(:html_headers?, headers)
    end

    test '#html_headers? returns false when Content-Transfer-Encoding is binary' do
      headers = { 'Content-Type' => 'text/html', 'Content-Transfer-Encoding' => 'binary' }
      refute @subject.send(:html_headers?, headers)
    end

    test '#take_html returns HTML String from Array' do
      html = '<h1>Example</h1>'
      body = [html]
      assert_equal @subject.send(:take_html, body), html
    end

    test '#take_html returns HTML String from ActionDispatch::Response' do
      html = '<h1>Example</h1>'
      body = [html]
      body = ActionDispatch::Response.new(*build_response(body: body))
      assert_equal @subject.send(:take_html, body), html
    end

    # Only use Rails 4.2+
    if defined? ActionDispatch::Response::RackBody
      test '#take_html returns HTML String from ActionDispatch::Response::RackBody' do
        html = '<h1>Example</h1>'
        body = [html]
        body = ActionDispatch::Response.new(*build_response(body: body))
        body = ActionDispatch::Response::RackBody.new(body)
        assert_equal @subject.send(:take_html, body), html
      end
    end

    test '#render returns the inline text' do
      html = '<h1>Example</h1>'
      assert_equal @subject.send(:render, inline: html), html
    end

    test '#controller returns nil when @env is nil' do
      refute @subject.send(:controller)
    end

    test '#controller returns the controller instance from @env' do
      controller = 'CONTROLLER'
      @subject.instance_variable_set(:@env, 'action_controller.instance' => controller)
      assert_equal @subject.send(:controller), controller
    end

    test '#assigns returns assings' do
      assigns = 'ASSINGS'

      view_context = MiniTest::Mock.new
      view_context.expect(:assigns, assigns)

      controller = MiniTest::Mock.new
      controller.expect(:view_context, view_context)

      @subject.stub(:controller, controller) do
        assert_equal @subject.send(:assigns), assigns
      end
    end

    test '#assigns returns assings when controller is nil' do
      @subject.stub(:controller, nil) do
        assert_instance_of Hash, @subject.send(:assigns)
        assert_empty @subject.send(:assigns)
      end
    end

    test '#helpers includes url helpers' do
      @subject.stub(:controller, nil) do
        @subject.stub(:engines_helpers, nil) do
          assert_includes @subject.send(:helpers), Rails.application.routes.url_helpers
        end
      end
    end

    test '#helpers includes controller helpers' do
      controller_helpers = 'CONTROLLER_HELPERS'

      controller = MiniTest::Mock.new
      controller.expect(:try, controller_helpers, [:_helpers])

      @subject.stub(:controller, controller) do
        @subject.stub(:engines_helpers, nil) do
          assert_includes @subject.send(:helpers), controller_helpers
        end
      end
    end

    test '#helpers includes engines helpers' do
      engines_helpers = 'ENGINES_HELPERS'
      @subject.stub(:controller, nil) do
        @subject.stub(:engines_helpers, engines_helpers) do
          assert_includes @subject.send(:helpers), engines_helpers
        end
      end
    end

    test '#engines_helpers returns a new module which includes a mounted helper' do
      url_helpers = 'URL_HELPERS'
      engine_name = 'dummy_engine'

      routes = MiniTest::Mock.new
      routes.expect(:url_helpers, url_helpers)

      engine_instance = MiniTest::Mock.new
      engine_instance.expect(:routes, routes)
      engine_instance.expect(:engine_name, engine_name)

      @subject.stub(:isolated_engine_instances, [engine_instance]) do
        wodule = @subject.send(:engines_helpers)
        klass = Class.new
        klass.send(:extend, wodule)
        assert_equal klass.send(engine_name), url_helpers
      end
    end

    test '#isolated_engine_instances returns instances of the isolated engine' do
      engine = Class.new(Rails::Engine)
      engine.stub(:isolated?, true) do
        assert_includes @subject.send(:isolated_engine_instances), engine.instance
      end
    end

    private

    def app(options = {})
      lambda { |env| build_response(options) }
    end

    def build_response(options)
      options
        .reverse_merge(default_app_options)
        .slice(:status, :headers, :body)
        .values
    end

    def default_app_options
      {
        status: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: ['<html><body>Example</body></html>']
      }
    end
  end
end
