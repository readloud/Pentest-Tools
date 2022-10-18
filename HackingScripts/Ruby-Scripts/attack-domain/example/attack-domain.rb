require 'attack-domain'
require 'pp'

domain1 = 'techarch.com.sa'
domain2 = 'zonetransfer.me'
domain3 = 'owa.zonetransfer.me'
domain4 = 'rubyfu.net'
domain5 = 'wikipedia.org'
ptr_ip1 = '54.221.226.67'    # rubyfu.net
ptr_ip2 = '207.46.197.32'    # owa.zonetransfer.me
ptr_ip3 = '91.198.174.192'   # wikipedia.org


core = Attack::Domain::Core.new
core.setup(nameserver: ['8.8.8.8', '8.8.4.4'], recurse: true, dnssec: false)
puts "[+] get_records_objects(domain)"
pp core.get_records_objects(domain3)

puts "\n[+] get_domainname"
pp core.get_domainname

puts "\n[+] get_ptr(domain_addr)"
pp core.get_ptr(ptr_ip1)
# pp core.get_ptr(ptr_ip2)
pp core.get_ptr(domain2)
pp core.get_ptr(domain4)

puts "\n[+] zone_transfer(domain)"
core.get_records_objects(domain2)
pp core.zone_transfer(domain2)
