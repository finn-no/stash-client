require 'webmock/rspec'
require 'stash/client'

# Disables the deprecation warning with RSpec 3.0
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
