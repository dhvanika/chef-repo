#
# Cookbook Name:: hostname
# Recipe:: default
#
# Copyright 2012, clarinova
#
# All rights reserved - Do Not Redistribute
#

file "/etc/hostname" do
  content "#{node.set_hostname.hostname}"
end

bash "update_hosts" do
  user "root"
  group "root"
  cwd "/tmp"
  environment ({'node' => node.set_hostname.hostname})
  code <<-EOH
  hostname $node
  EOH
end

ruby_block "edit /etc/hosts" do
  block do
    file = Chef::Util::FileEdit.new("/etc/hosts")
     # the 127.0.1.1 address is particular to vagrant; need to do and if/else for final
    file.search_file_replace_line(/127.0.1.1/, "127.0.1.1 #{node.set_hostname.hostname}")
    file.write_file
  end
  action :create
end
