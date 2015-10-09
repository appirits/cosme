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
          assert_equal @subject.call(nil), response
        end
      end
    end

    test '#call does nothing when the response is not html' do
      response = 'RESPONSE'
      app = @subject.instance_variable_get(:@app)
      app.stub(:call, response) do
        @subject.stub(:response_to_html, nil) do
          assert_equal @subject.call(nil), response
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
            assert_equal @subject.call(nil), new_response
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
