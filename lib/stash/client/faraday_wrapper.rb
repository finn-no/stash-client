module Stash
  class Client
    class FaradayWrapper

      attr_reader :client
      def initialize(url, opts)
        @client = Faraday.new(url, opts)
      end

      def fetch(uri, headers = {})
        res = client.get do |req|
          req.url uri
          req.headers.update(headers)
        end
      end

      def post(uri, data, headers = {})
        res = client.post do |req|
          req.url uri
          req.body = data

          req.headers.update(headers)
        end
      end

      def put(uri, data = '', headers = {})
        res = client.put do |req|
          req.url uri
          req.body = data

          req.headers.update(headers)
        end
      end

      def delete(uri, headers = {})
        res = @client.delete do |req|
          req.url uri
          req.headers.update(headers)
        end
      end


    end
  end
end
