
puts "Hostname " +node['hostname']+" "+node['ipaddress']

search('hosts', "*:*").each do |host|
  Chef::Log.info("HOST: #{host['id']}: #{host['ip']}")
end

host = find_host_data(node)

puts Chef::Config.keys
puts Chef::Config[:json_attribs]
puts Chef::Config[:node_path]
puts Chef::Config[:node_name]

#puts node.to_yaml

bash "Do A Little Test" do
  user "root"
  code <<-EOH
  date > /tmp/chef-test
  EOH
end


