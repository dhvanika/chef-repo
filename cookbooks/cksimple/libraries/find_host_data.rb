
if (defined? require_relative).nil?
  # definition of 'require_relative' for ruby < 1.9, found on stackoverflow.com
  def require_relative(relative_feature)
    c = caller.first
    fail "Can't parse #{c}" unless c.rindex(/:\d+(:in `.*')?$/)
    file = $`
    if /\A\((.*)\)/ =~ file # eval, etc.
      raise LoadError, "require_relative is called in #{$1}"
    end
    absolute = File.expand_path(relative_feature, File.dirname(file))
    require absolute
  end
end

require_relative 'search.rb'

#
# Match the IP addresses for this host to the hosts in the data bags, 
# and return the match
# 
def find_host_data(node)

  addresses = []
  node['network']['interfaces'].each do |k,v|

    if v.is_a?(Mash) and v.has_key?('addresses')
      v['addresses'].each do |k,v|
        if not k.include? ':'  #Only IP V4
          addresses << k
        end
      end
    end
  end

  addresses.each do |address|
    search('nodes', "ip:#{address}").each do |host|
      #Chef::Log.info("FOUND: #{address} #{host['id']}: #{host['ip']}")
      return host
    end
  end

  nil

end
