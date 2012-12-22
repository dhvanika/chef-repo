#
# Find the host record based on the IP address of this node, then
# write the host record to the node json file. 
# 


# Find the host data based on the IP of this machine, using the 'host' data bag. 
host = find_host_data(node)

file Chef::Config[:json_attribs] do
  content host.raw_data.to_json
  Chef::Log.info("Writing node data to: "+Chef::Config[:json_attribs]+"-foo")
  #notifies :run, resources(:execute => "Configure Hostname"), :immediately
end


