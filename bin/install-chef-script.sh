# Basic install for chef-solo
# Stolen from https://raw.github.com/karmi/chef-solo-hello-world/master/bootstrap.sh

R=`which ruby` || R='/opt/vagrant_ruby/bin/ruby'

test -x $R && $R -e 'File.mtime("/var/lib/apt/lists/partial/") < Time.now - 3600 ? exit(1) : exit(0)' > /dev/null  2>&1 || \
  (
  # Update packages
  #
  echo '-- Updating packages ---------';
  apt-get update --quiet --yes && \
  #
  # Install curl and vim
  #
  echo '-- Installing curl and vim ---';
  apt-get install curl vim --quiet --yes
  )

test -d "/opt/chef" || \
  (
  # Install Chef ("omnibus")
  #
  echo '-- Installing Chef -----------';
  curl -# -L http://www.opscode.com/chef/install.sh | bash
  )

# Create neccessary Chef resources and configs
#

mkdir -p /tmp/cookbooks /tmp/site-cookbooks
mkdir -p /var/chef-solo /var/chef/site-cookbooks /var/chef/cookbooks /etc/chef /var/chef/nodes

rm -rf /var/chef/cookbooks/* /var/chef/recipes.tgz /var/chef/cache/*

cd /var/chef-solo
curl -# -L http://chef.clarinova.net.s3.amazonaws.com/chef-repo-data.tar.gz  | tar -xzvf - 



cat > /etc/chef/solo.rb<<EOM
file_cache_path "/var/chef-solo"
json_attribs "/var/chef/nodes/node.json"
recipe_url "http://chef.clarinova.net/chef-repo.tar.gz"
data_bag_path "/var/chef-solo/data_bags"
EOM

cat > /var/chef/nodes/node.json<<EOM
{
    
}

EOM


chef-solo -o cksimple::configurenode
