require 'spec_helper'

module Stash
  describe Client do
    let(:client) { Client.new(host: 'git.example.com', credentials: 'foo:bar') }

    def response_with_value(params)
      {
        'values' => [params],
        'isLastPage' => true,
        'start' => 0,
        'size' => 1
      }.to_json
    end

    it 'fetches projects' do
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects").to_return(body: response_with_value('key' => 'value'))
      client.projects.should == [{"key" => "value"}]
    end

    it 'fetches repositories' do
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects").to_return(body: response_with_value('link' => {'url' => '/projects/foo'}))
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects/foo/repos").to_return(body: response_with_value('key' => 'value'))

      client.repositories.should == [{'key' => 'value'}]
    end

    it 'fetches repositories_for' do
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects/foo/repos").to_return(body: response_with_value('key' => 'value'))

      project = {
        'link' => {
          'url' => 'foo:bar@git.example.com/rest/api/1.0/projects/foo',
        }
      }
      client.repositories_for(project).should == [{'key' => 'value'}]
    end

    it 'fetches commits' do
      stub_request(:get, 'foo:bar@git.example.com/rest/api/1.0/repos/foo/commits?limit=100').to_return(body: response_with_value('key' => 'value'))
      client.commits_for({'link' => {'url' => '/repos/foo/browse'}}).should == [{'key' => 'value'}]
    end

    it 'feches changes' do
      stub_request(:get, 'foo:bar@git.example.com/rest/api/1.0/projects/foo/repos/bar/changes?limit=100&until=deadbeef').to_return(body: response_with_value('key' => 'value'))
      
      repo = {'link' => {'url' => '/projects/foo/repos/bar/browse'}}
      client.changes_for(repo, 'deadbeef', limit: 100).should == [{'key' => 'value'}]
    end

    it 'respects since/until when fetching commits' do
      stub_request(:get, 'foo:bar@git.example.com/rest/api/1.0/repos/foo/commits?since=cafebabe&until=deadbeef').to_return(body: response_with_value('key' => 'value'))
      client.commits_for({'link' => {'url' => '/repos/foo/browse'}}, since: 'cafebabe', until: 'deadbeef').should == [{'key' => 'value'}]
    end

  end
end
