require 'spec_helper'
require 'oauth'

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

    context "oauth" do
      let(:client) {
        Client.new(
          url: 'https://git.example.com',
          oauth: {
            key: 'key',
            secret: IO.read(File.dirname(__FILE__) + "/../../spec/key.pem"),
            access_token: 'foo',
            access_token_secret: 'bar'
          }
        )
      }

      it 'uses OAuthWrapper class' do
        client.client.stub(:fetch).and_return(Struct.new(nil, :body).new(response_with_value('key' => 'value')))
        client.projects.should == [{"key" => "value"}]
      end
    end

    it 'fetches file content' do
      stub_request(:get, "http://foo:bar@git.example.com/projects/PROJ_KEY/repos/repo/browse/file.txt?at=4367b0f892a166f3e3fa3ae54d74e897af1007a8&raw=").to_return(body: "file content")
      client.content(project_key: 'PROJ_KEY', repository_name: 'repo', path: 'file.txt', ref: '4367b0f892a166f3e3fa3ae54d74e897af1007a8').should == 'file content'
    end

    it 'fetches projects' do
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects").to_return(body: response_with_value('key' => 'value'))
      client.projects.should == [{"key" => "value"}]
    end

    it 'creates projects' do
      stub_request(:post, "foo:bar@git.example.com/rest/api/1.0/projects").
        with(:body => {:key => 'FOO', :name => 'Foobar', :description => 'bar'}).
        to_return(:body => {
          'id' => 1,
          'key' => 'FOO',
          'name' => 'Foobar',
          'description' => 'bar',
          'public' => true,
          'type' => 'NORMAL',
          'link' => {
            'url' => 'http://git.example.com/projects/FOO',
            'rel' => 'self',
          },
          'links' => {
            'self' => [
              { 'href' => 'http://git.example.com/projects/FOO' },
            ],
          },
        }.to_json)

      client.create_project({
        :key => 'FOO', :name => 'Foobar', :description => 'bar'
      }).should == {
        'id' => 1,
        'key' => 'FOO',
        'name' => 'Foobar',
        'description' => 'bar',
        'public' => true,
        'type' => 'NORMAL',
        'link' => {
          'url' => 'http://git.example.com/projects/FOO',
          'rel' => 'self',
        },
        'links' => {
          'self' => [
            { 'href' => 'http://git.example.com/projects/FOO' },
          ],
        },
      }
    end

    it 'updates projects' do
      stub_request(:put, "foo:bar@git.example.com/rest/api/1.0/projects/foo").
        with(:body => {:description => 'new description'}).
        to_return(:body => {
          'description' => 'new description',
        }.to_json)

      project = { 'link' => {'url' => '/projects/foo'} }
      client.update_project(project, {
        :description => 'new description'
      }).should == {
        'description' => 'new description',
      }
    end

    it 'deletes projects' do
      stub_request(:delete, "foo:bar@git.example.com/rest/api/1.0/projects/foo").
        to_return(:status => 200, :body => "")

      project = { 'link' => {'url' => '/projects/foo'} }
      client.delete_project(project).should == ""
    end

    it 'fetches repositories' do
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects").to_return(body: response_with_value('link' => {'url' => '/projects/foo'}))
      stub_request(:get, "foo:bar@git.example.com/rest/api/1.0/projects/foo/repos").to_return(body: response_with_value('key' => 'value'))

      client.repositories.should == [{'key' => 'value'}]
    end

    it 'fetches commits' do
      stub_request(:get, 'foo:bar@git.example.com/rest/api/1.0/repos/foo/commits?limit=100').to_return(body: response_with_value('key' => 'value'))
      client.commits_for({'link' => {'url' => '/repos/foo/browse'}}).should == [{'key' => 'value'}]
    end

    it 'fetches changes' do
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
