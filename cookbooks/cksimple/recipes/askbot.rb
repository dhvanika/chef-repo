
#
# Install askbot
#

user_name = node[:user][:name]
user_dir = "/home/#{user_name}"
password = node[:user][:password]

virt_dir =  "#{user_dir}/virt"
install_dir = "#{virt_dir}/src/askbot-app"

execute "apt-get update"

package 'python-dev' 
package 'python-pip' 
package 'python-virtualenv'

package 'git-core' 
package 'subversion' 
package 'mercurial'

bash "configure firewall" do
  user "root"
  code <<-EOH
  #ufw allow 8000
  #ufw alllow ssh
  #ufw allow nfs
  ufw disable
  EOH
end

directory "#{user_dir}/data" do
  owner "#{user_name}"
  group "users"
  mode "0755"
  action :create
end


python_virtualenv "#{user_dir}/virt" do
  owner "#{user_name}"
  group "users"
  action :create
end


ruby_block "prep profile" do
  block do
    
    file = Chef::Util::FileEdit.new("#{user_dir}/virt/bin/activate")
    file.insert_line_if_no_match(/#pythonpath/, "export PYTHONPATH=\"#{install_dir}\" #pythonpath\n")
    file.write_file
    
    # Need to write it twice to get both lines in the file
    file = Chef::Util::FileEdit.new("#{user_dir}/.bash_profile")
    file.insert_line_if_no_match(/#activate/, "source #{user_dir}/virt/bin/activate #activate\n")
    file.write_file
    
    file = Chef::Util::FileEdit.new("#{user_dir}/.bash_profile")
    file.insert_line_if_no_match(/#chdir/, "cd #{install_dir} #chdir\n")
    file.write_file    
  end
  action :create
end

app_user_a = node[:postgresql][:app_db][:user]
app_user_name = node[:postgresql][app_user_a][:name]
app_user_pw = node[:postgresql][app_user_a][:password]
app_db_name = node[:postgresql][:app_db][:name] 

bash "install askbot" do
  user "#{user_name}"
  group "users"
  cwd "#{user_dir}"
  environment ({'nil' => nil})
  code <<-EOH
  source #{user_dir}/virt/bin/activate
  pip install psycopg2
  pip install -e 'git+https://github.com/clarinova/askbot-devel.git#egg=askbot-app'
  EOH
end

bash "configure askbot 1" do
  user "#{user_name}"
  group "users"
  cwd "#{user_dir}"
  environment ({'nil' => nil})
  code <<-EOH
  source #{user_dir}/virt/bin/activate
  cd #{install_dir}
  python setup.py develop 
  #askbot-setup  -v 2 -e 1 -n `pwd` -d askbotdb -u askbot -p askbot
  askbot-setup -v 2 -n #{install_dir} -e 1 -d #{app_db_name} -u #{app_user_name} -p #{app_user_pw}
  echo RAN: askbot-setup -v 2 -n #{install_dir} -e 1 -d #{app_db_name} -u #{app_user_name} -p #{app_user_pw}
  
  EOH
end

bash "configure askbot 2" do
  user "#{user_name}"
  group "users"
  cwd "#{install_dir}"
  environment ({'nil' => nil})
  code <<-EOH
  source #{user_dir}/virt/bin/activate

  python manage.py syncdb
  
  python manage.py migrate askbot
  
  python manage.py migrate django_authopenid
  
  EOH
end





