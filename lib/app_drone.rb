requires = %w(version template integration object_extensions)
requires.each { |r| require "app_drone/#{r}" }

require 'app_drone/integrations/gems/gems'

# TODO require all integrations in the directory

module AppDrone
  # TODO Your code goes here...
end
