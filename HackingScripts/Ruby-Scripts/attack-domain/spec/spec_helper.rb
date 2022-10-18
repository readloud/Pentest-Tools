#
# RSpec configurations
#
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

#
# Output
#
def outputs(output)
  puts "[---] OUTPUT"
  ap output
  puts "[-----END OF OUTPUT-----]\n\n\n"
end

# $LOAD_PATH.unshift File.expand_path('../../lib/', __FILE__)
unless $LOAD_PATH.include? File.expand_path(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))  # Spec
  # $LOAD_PATH.unshift(File.expand_path(File.join('..','lib')))
end

#
# Requirements
#
require 'awesome_print'
require 'pp'
require 'attack/domain'
require 'attack/domain/core'
require 'attack/domain/version'

