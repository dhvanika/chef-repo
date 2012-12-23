#
# Find the host record based on the IP address of this node, then
# write the host record to the node json file. 
# 

package "make"
package "libshadow-ruby1.8"
gem_package "ruby-shadow"

ruby_block "require shadow library" do
  block do
    Gem.clear_paths  # <-- Necessary to ensure that the new library is found
    #require 'shadow' # <-- gem is 'ruby-shadow', but library is 'shadow'
  end
end.run_action(:create)

host = find_host_data(node)

puts "Hostname "+host['hostname']

# Merge the host data into the node data, and put it back in the file. 
attribs = JSON.parse(IO.read(Chef::Config[:json_attribs] ))
attribs = attribs.merge(host.raw_data)
node.consume_attributes(attribs)

file Chef::Config[:json_attribs] do 
  content attribs.to_json
end.run_action(:create)

Chef::Log.info("Updated node json attrbutes in #{Chef::Config[:json_attribs]}")


file "/etc/hostname" do
  content host['name']
  mode "0644"
end.run_action(:create)

execute "hostname #{host['hostname']}"

#
# This structure of the hosts file, which uses 127.0.1.1 to set values for hostname --fqdn, 
# seems to be particular to Ubuntu. 
#
template "/etc/hosts" do
  user 'root'
  group 'root'
  mode '0644'
  variables(
      :hostname => host['hostname'], 
      :name => host['name'], 
      :hosts => search('hosts','*:*')
  )
  source "hosts.erb"
end.run_action(:create)

ohai "reload" do
  action :nothing
end.run_action(:reload)

#package 'make' #required to install ruby-shadow 
#chef_gem "ruby-shadow" do #required for the user provider
#  action :install
#end



