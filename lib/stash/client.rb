require 'stash/client/version'
require 'faraday'
require 'addressable/uri'
require 'json'

module Stash
  class Client

    attr_reader :url

    def initialize(opts = {})
      if opts[:client]
        @client = opts[:client]
      else
        if opts[:host] && opts[:scheme]
          @url = Addressable::URI.parse(opts[:scheme] + '://' + opts[:host] + '/rest/api/1.0/')
        elsif opts[:host]
          @url = Addressable::URI.parse('http://' + opts[:host] + '/rest/api/1.0/')
        elsif opts[:url]
          @url = Addressable::URI.parse(opts[:url])
        elsif opts[:uri] && opts[:uri].kind_of?(Addressable::URI)
          @url = opts[:uri]
        else
          raise ArgumentError, "must provide :url or :host"
        end

        @url.userinfo = opts[:credentials] if opts[:credentials]

        @client = Faraday.new(@url.site)
      end

    end

    def projects
      fetch_all @url.join('projects')
    end

    def create_project(opts={})
      post @url.join('projects'), opts
    end

    def update_project(project, opts={})
      relative_project_path = project.fetch('link').fetch('url')
      put @url.join(remove_leading_slash(relative_project_path)), opts
    end

    def delete_project(project)
      relative_project_path = project.fetch('link').fetch('url')
      delete @url.join(remove_leading_slash(relative_project_path))
    end

    def repositories
      projects.map do |project|
        relative_project_path = project.fetch('link').fetch('url') + '/repos'
        fetch_all @url.join(remove_leading_slash(relative_project_path))
      end.flatten
    end

    def project_named(name)
      projects.find { |e| e['name'] == name }
    end

    def repository_named(name)
      repositories.find { |e| e['name'] == name }
    end

    def update_repository(repo, opts = {})
      relative_project_path = repo.fetch('link').fetch('url')
      put @url.join(remove_trailing_browse(remove_leading_slash(relative_project_path))), opts
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

    def changes_for(repo, sha, opts = {})
      path = remove_leading_slash repo.fetch('link').fetch('url').sub('browse', 'changes')
      uri = @url.join(path)

      query_values = { 'until' =>  sha }
      query_values['since'] = opts[:parent] if opts[:parent]
      query_values['limit'] = opts[:limit] if opts[:limit]

      uri.query_values = query_values

      if query_values['limit']
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
      res = @client.get { |req|
        req.url uri.to_s
        req.headers['Accept'] = 'application/json'
      }

      parse(res.body)
    end

    def post(uri, data)
      res = @client.post { |req|
        req.url uri.to_s
        req.body = data.to_json

        req.headers['Content-Type'] = 'application/json'
        req.headers['Accpet']       = 'application/json'
      }

      parse(res.body)
    end

    def put(uri, data)
      res = @client.put { |req|
        req.url uri.to_s
        req.body = data.to_json

        req.headers['Content-Type'] = 'application/json'
        req.headers['Accpet']       = 'application/json'
      }

      parse(res.body)
    end

    def delete(uri)
      res = @client.delete { |req|
        req.url uri.to_s
        req.headers['Accpet']       = 'application/json'
      }

      res.body
    end

    def parse(str)
      JSON.parse(str)
    rescue Encoding::InvalidByteSequenceError
      # HACK
      JSON.parse(str.force_encoding("UTF-8"))
    end

    def remove_leading_slash(str)
      str.sub(/\A\//, '')
    end

    def remove_trailing_browse(str)
      str.sub('/browse', '')
    end
  end
end
