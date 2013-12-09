# Stash::Client

Very basic client for the Atlassian Stash REST API.

## Installation

Add this line to your application's Gemfile:

    gem 'stash-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stash-client

## Usage

```ruby
client = Stash::Client.new(host: 'git.example.com', credentials: 'user:pass')
client.projects #=> [{'name' => 'foo', ...}]

repo    = client.repositories.first #=> {'name' => 'bar', ...}
commits = client.commits_for(repo, since: 'e6c0a79734b3c1fa5c30c4c83cd3220e36d7e246')
commits = client.commits_for(repo, limit: 100)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes and add tests for it. This is important so we don't break it in a future version unintentionally.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
