require "stash/client/version"
require "restclient"
require 'addressable/uri'
require 'json'

module Stash
  class Client

    attr_reader :url

    def initialize(opts = {})
      if opts[:host] && opts[:scheme]
        @url = Addressable::URI.parse(opts[:scheme] + '://' + opts[:host] + '/rest/api/1.0/')
      elsif opts[:host]
        @url = Addressable::URI.parse('http://' + opts[:host] + '/rest/api/1.0/')
      elsif opts[:url]
        @url = Addressable::URI.parse(opts[:url])
      elsif opts[:uri] && opts[:uri].kind_of?(Addressable::URI)
        @url = opts[:uri]
      else
        raise ArgumentError, "must provie :url or :host"
      end

      @url.userinfo = opts[:credentials] if opts[:credentials]
    end

    def projects
      fetch_all @url.join('projects')
    end

    def repositories
      projects.flat_map do |project|
        relative_project_path = project.fetch('link').fetch('url') + '/repos'
        fetch_all @url.join(remove_leading_slash(relative_project_path))
      end
    end

    def project_named(name)
      projects.find { |e| e['name'] == name }
    end

    def repository_named(name)
      repositories.find { |e| e['name'] == name }
    end

    def commits_for(repo, opts = {})
      query_values = {}

      path = remove_leading_slash repo.fetch('link').fetch('url').sub('browse', 'commits')
      uri = @url.join(path)

      query_values['since'] = opts[:since] if opts[:since]
      query_values['until'] = opts[:until] if opts[:until]
      query_values['limit'] = Integer(opts[:limit]) if opts[:limit]

      if query_values.empty?
        # default limit to 100 commits
        query_values['limit'] = 100
      end
      
      uri.query_values = query_values

      if query_values['limit'] && query_values['limit'] < 100
        fetch(uri).fetch('values')
      else
        fetch_all(uri)
      end
    end

    private

    def fetch_all(uri)
      response, result = {}, []

      until response['isLastPage']
        response = fetch(uri)
        result += response['values']

        next_page_start = response['nextPageStart'] || (response['start'] + response['size'])
        uri.query_values = (uri.query_values || {}).merge('start' => next_page_start)
      end

      result
    end

    def fetch(uri)
      JSON.parse(RestClient.get(uri.to_s, :accept => "application/json"))
    end

    def remove_leading_slash(str)
      str.sub(/\A\//, '')
    end

  end
end
