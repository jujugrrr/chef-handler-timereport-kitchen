# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

::LOG_LEVEL = :debug
::CENTOS_OPTS = {
  platform: 'centos',
  version: '6.5',
  log_level: ::LOG_LEVEL
}
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

at_exit { ChefSpec::Coverage.report! }
