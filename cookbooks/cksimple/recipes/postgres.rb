#puts "This is a print statement for host  #{node.solr.hostname}, "
#Chef::Log.info('This is a log entry')

print "Server password: #{node[:postgresql][:postgres][:password]} "

pg_user_name = node[:postgresql][:postgres][:name]
pg_user_pw = node[:postgresql][:postgres][:password]

app_user_a = node[:postgresql][:app_db][:user]
app_user_name = node[:postgresql][app_user_a][:name]
app_user_pw = node[:postgresql][app_user_a][:password]

app_db_name = node[:postgresql][:app_db][:name]

package 'postgresql-9.1' 
package 'postgresql-client-9.1' 
package 'postgresql-server-dev-9.1' 
package 'libpq-dev'

# Replace the line with this hostname with a local entry
ruby_block "edit /etc/postgresql/9.1/main/pg_hba.conf" do
  block do
    file = Chef::Util::FileEdit.new("/etc/postgresql/9.1/main/pg_hba.conf")
    file.insert_line_if_no_match(/#local_socket_access/, 
            "local #{app_db_name} #{app_user_name} md5 #local_socket_access\n")
    file.write_file  
    # The    insert_line_if_no_match function doesn't insert more than one new line at the end of a file.        
    file = Chef::Util::FileEdit.new("/etc/postgresql/9.1/main/pg_hba.conf")
    file.insert_line_if_no_match(/#local_network_access/, 
            "host   all   all   192.168.0.0/16  md5 #local_network_access\n")
    file.write_file
  end
end

ruby_block "edit /etc/postgresql/9.1/main/postgresql.conf" do
  block do
    file = Chef::Util::FileEdit.new("/etc/postgresql/9.1/main/postgresql.conf")
    file.search_file_replace_line(/^#listen_addresses/, "listen_addresses = '*'")
    file.write_file
  end
  action :create
end

bash "postgres password" do
  user "postgres"
  code <<-EOH
  createuser -S -D -R #{app_user_name}
  echo "ALTER USER #{pg_user_name} with password '#{pg_user_pw}';" | psql
  echo "ALTER USER #{app_user_name} with password '#{app_user_pw}';" | psql
  createdb -O #{app_user_name} #{app_db_name}
  EOH
end
params[:id]

#execute 'ufw disable' do
#  action :run
#  user 'root'
#  command "ufw disable"
# end

service "postgresql" do
  action [:restart, :enable]
end