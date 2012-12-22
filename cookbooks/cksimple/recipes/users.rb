package 'make' #reqiuired to install ruby-shadow 

gem_package "ruby-shadow" do
  action :install
  ignore_failure true
end

node[:users].each do |user_name,user|

  user_dir = "/home/#{user_name}"
  password = user[:password]

  user "#{user_name}" do
    comment "#{user_name} user"
    gid "users"
    home "#{user_dir}"
    shell "/bin/bash"
    password "#{password}" # openssl passwd -1 "askbot"
  end

  user "#{user_name}" do
    action :lock
  end

  directory "#{user_dir}" do
    owner "#{user_name}"
    group "users"
    mode "0755"
    action :create
  end

  template "#{user_dir}/.bash_profile" do
    owner 'root'
    source "bash_profile.erb" 
    mode "0600"
    variables({
      :user_name => user_name
      })
    end

    bash "finalize" do
      user "root"
      group "users"

      code <<-EOH
      # Make everything owned by the ckan user
      chown -R #{user_name}.users #{user_dir}
      # Make User a sudoer
      groupadd -f admin
      usermod -g admin #{user_name}
      EOH
    end
end