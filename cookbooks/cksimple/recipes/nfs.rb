
package 'nfs-kernel-server'

directory "/export/askbot" do
  owner "askbot"
  group "users"
  mode "0755"
  recursive true
  action :create
end

ruby_block "setup-nfs" do
  block do
    
    # Need to write it twice to get both lines in the file
    file = Chef::Util::FileEdit.new("/etc/exports")
    file.insert_line_if_no_match(/#export/, "/export 192.168.0.0/16(rw,fsid=0,insecure,no_subtree_check,async,all_squash,anonuid=2001,anongid=100) #export\n")
    file.write_file
    
    file = Chef::Util::FileEdit.new("/etc/exports")
    file.insert_line_if_no_match(/#askbot/, "/export/askbot 192.168.0.0/16(rw,nohide,insecure,no_subtree_check,async,all_squash,anonuid=2001,anongid=100) #askbot\n")
    file.write_file
    
    file = Chef::Util::FileEdit.new("/etc/fstab")
    file.insert_line_if_no_match(/#askbot/, "/home/askbot    /export/askbot   none    bind  0  0 #askbot")
    file.write_file    
  end
  action :create
end

service "nfs-kernel-server" do
  action [:restart, :enable]
end


bash "finalize" do
  user "root"
  group "users"

  code <<-EOH
  # Mount the bind directory for nfs
  mount -a
EOH
end