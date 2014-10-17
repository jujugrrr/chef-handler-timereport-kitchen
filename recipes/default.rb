cookbook_file "#{node["chef_handler"]["handler_path"]}/timereport.rb" do
  source 'chef-handler-timereport/lib/chef/handler/timereport.rb'
end

chef_handler 'Chef::Handler::TimeReport' do
  source "#{node["chef_handler"]["handler_path"]}/timereport.rb"
  arguments :debug => true
  action :enable
end

include_recipe 'yum'

bash 'medium_bash' do
  code 'sleep 1'
end

package 'bash'

bash 'long_bash' do
  code 'sleep 2'
end
