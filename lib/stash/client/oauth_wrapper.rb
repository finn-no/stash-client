require 'oauth'

module Stash
  class Client
    class OAuthWrapper

      attr_reader :consumer, :access_token
      def initialize(url, opts)

        @consumer ||= OAuth::Consumer.new(
          opts[:oauth][:key],
          OpenSSL::PKey::RSA.new(opts[:oauth][:secret]),
          {
          :site => url,
          :signature_method => 'RSA-SHA1',
          :scheme => :header,
          :http_method => :post,
          :request_token_path=> '/plugins/servlet/oauth/request-token',
          :access_token_path => '/plugins/servlet/oauth/access-token',
          :authorize_path => '/plugins/servlet/oauth/authorize'
        })
        @access_token = OAuth::AccessToken.new(@consumer, opts[:oauth][:access_token], opts[:oauth][:access_token_secret])
      end

      def fetch(path, headers = {})
        access_token.get(path, headers)
      end

      def post(path, body = '', headers = {})
        access_token.post(path, body, headers)
      end

      def put(path, body = '', headers = {})
        access_token.put(path, body, headers)
      end

      def delete(path, headers = {})
        access_token.delete(path, headers)
      end

    end
  end
end
