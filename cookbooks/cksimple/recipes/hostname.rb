

include_recipe "cksimple::overidenode"

file "/etc/hostname" do
  content node.host.name
  #notifies :run, resources(:execute => "Configure Hostname"), :immediately
end

bash "update_hosts" do
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
  hostname #{node.host.name}
  EOH
end


template "/etc/hosts" do
  user 'root'
  group 'root'
  mode '0644'
  variables(
      :hostname => node.host.name, # Not used
      :hosts => search('hosts','*:*')
  )
  source "hosts.erb"
end

# Replace the line with this hostname with a local entry
ruby_block "edit /etc/hosts" do
  block do
    file = Chef::Util::FileEdit.new("/etc/hosts")
     # the 127.0.1.1 address is particular to vagrant; need to do an if/else for production
    file.search_file_replace_line(/#{Regexp.quote(node.host.name)}/, "127.0.0.1 localhost #{node.host.name}")
    file.write_file
  end
  action :create
end
