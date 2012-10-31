#puts "This is a print statement for host  #{node.solr.hostname}, "
#Chef::Log.info('This is a log entry')

print "Server password: #{node['postgresql']['password']['postgres']} "

# Replace the line with this hostname with a local entry
ruby_block "edit /etc/postgresql/8.4/main/pg_hba.conf" do
  block do
    file = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/pg_hba.conf")
    file.insert_line_if_no_match(/#local network access/, "host all all 192.168.33.0/24 md5 #local network access")
    file.write_file
  end
  action :create
end

ruby_block "edit /etc/postgresql/8.4/main/postgresql.conf" do
  block do
    file = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/postgresql.conf")
    file.search_file_replace_line(/^listen_addresses/, "listen_addresses = '*'")
    file.write_file
  end
  action :create
end

execute 'ufw disable' do
  action :run
  user 'root'
  command "ufw disable"
end


service "postgresql-8.4" do
  action [:restart, :enable]
end