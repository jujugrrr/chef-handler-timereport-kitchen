# Encoding: utf-8

require_relative 'spec_helper'

describe 'handler-project::default' do
  let(:chef_run) { ChefSpec::Runner.new(CENTOS_OPTS).converge(described_recipe) }

  it 'runs chef' do
#    skip "fake"
    expect(chef_run).to_not start_service('a')
  end
end
