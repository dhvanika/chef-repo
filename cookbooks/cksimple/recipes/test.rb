puts "############ TEST ################"
puts "Hostname " +node['hostname']+" "+node['ipaddress']
puts "NODE "+Chef::Config[:node_name]
#puts Chef::Config.keys
puts Chef::Config[:json_attribs]
puts Chef::Config[:node_path]

search('hosts', "*:*").each do |host|
  Chef::Log.info("HOST: #{host['id']}: #{host['ip']}")
end

host = find_host_data(node)
puts host.raw_data.to_yaml
puts '---- attributes ----- '
attribs = JSON.parse(IO.read(Chef::Config[:json_attribs] ))
attribs = attribs.merge(host.raw_data)
puts attribs.to_yaml
puts "############################"

user = search(:users,"id:askbot").first()
print user
 

