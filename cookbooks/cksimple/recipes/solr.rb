
#
# Install solr
#

execute 'mv schema' do
  action :run
  user 'root'
  command "apt-get update"
end

package 'solr-jetty' 
package 'openjdk-6-jdk'
package 'default-jdk' 

ruby_block "jetty config" do
  block do
    file = Chef::Util::FileEdit.new("/etc/default/jetty")
    file.search_file_replace_line(/NO_START=/, "NO_START=0")
    file.search_file_replace_line(/JETTY_HOST=/, "JETTY_HOST=0.0.0.0")
    file.search_file_replace_line(/JETTY_PORT=/, "JETTY_PORT=8983")
    file.write_file
  end
  action :create
end

execute 'ufw disable' do
  action :run
  user 'root'
  command "ufw disable"
end

service "jetty" do
  action :start
end

execute 'mv schema' do
  action :run
  user 'root'
  command "mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak"
end

cookbook_file "/etc/solr/conf/schema.xml" do
  owner 'root'
  source "ckan-schema-1.4.xml" 
  mode "0644"
end

service "jetty" do
  action [:restart, :enable]
end
