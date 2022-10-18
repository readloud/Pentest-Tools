#
#
#
#
#
#
require 'dnsruby'
require 'ipaddr'

module Attack
module Domain
  
  #
  # Core contains all core/basic operations. Basically, it's to simplify what we need from Dnsruby
  #
  # @attr_accessor [String] domain optionally assign domain
  # @attr_accessor [Array<String>]
  #
  #
  # @example:
  #   core = Attack::Domain::Core.new('techarch.com.sa', ['8.8.8.8', '8.8.4.4'])
  #   core.nameservers # => ['8.8.8.8', '8.8.4.4']
  #   core.mx #=> [ 'mail1.techarch.com.sa' => ['x1.x1.x1.x1', 'x2.x2.x2.x2'] ]
  #
  class Core
    
    # Default nameservers
    DEFAULT_NAMESERVER = ['8.8.8.8', '8.8.4.4']
    # Dnsruby::Name::Label::MaxLabelLength = 2000   # Trying to fix in get_label': Label too long (111, max length=64) error
    
    # Domain to be processed
    attr_accessor :domain
    
    # Nameserver(s), in-case we want to update it for zone transfer or something else
    attr_accessor :nameserver
    
    # records_objects contains all records object for parsed domain/IP
    attr_reader :records_objects

    def initialize
      @core = Dnsruby::Resolver.new
      @core.nameserver = DEFAULT_NAMESERVER
      @get_records_objects = ''
    end
    
    #
    # setup is a place holder to all important configurations
    # for the instance variable @resolver which is an instance of
    # Dnsruby::Reolver class
    #
    # @param [Hash] config
    # @option opts [Array<String>]  :nameserver default {Core::DEFAULT_NAMESERVER DEFAULT_NAMESERVER}
    # @option opts [Integer] :retry_times
    # @option opts [Boolean] :recurse
    # @option opts [Boolean] :dnssec
    #
    # @example:
    #   setup({nameserver: ['8.8.4.4'], retry_time: 2, recurse: true})
    #
    # @return self
    #
    def setup(config={})
      @core.nameserver  = config[:nameserver]  || DEFAULT_NAMESERVER
      @core.retry_times = config[:retry_times] || 2
      @core.recurse     = config[:recurse]     || true
      @core.dnssec      = config[:dnssec]      || true
      
      self
    end
    
    #
    # get_records_objects querying 'ANY' record and parses the given domain's answer
    # @note: it does not parse the {Dnsruby::Header} header
    #
    # @param [String] domain
    #
    # @return [Hash{Symbol => Array<>}]
    #
    def get_records_objects(domain)
      query  = @core.query(domain, 'ANY', 'IN')
      answer = query.answer


      @records_objects =
      {
          ns:    'NS',       # Name Server
          soa:   'SOA',      # Start Of Authority
          a:     'A',        # A record
          aaaa:  'AAAA',     # v6 A record
          txt:   'TXT',      # TEXT
          mx:    'MX',       # Mail Exchange
          cname: 'CNAME',    # Canonical Name
          srv:   'SRV',      # Service Record
          hinfo: 'HINFO',    # Host Information
          axfr:  'AXFR',     #
          ixfr:  'IXFR'
      }

      @records_objects.map do |key, val|
        
        @records_objects[key] = answer.select { |r| r.type == val }
        
      end
      
      # p @records_objects
      # exit
    #   @records_objects =
    #   {
    #       ns:    answer.select { |r| r.type == 'NS' },       # Name Server
    #       soa:   answer.select { |r| r.type == 'SOA' },      # Start Of Authority
    #       a:     answer.select { |r| r.type == 'A' },        # A record
    #       aaaa:  answer.select { |r| r.type == 'AAAA' },     # v6 A record
    #       txt:   answer.select { |r| r.type == 'TXT' },      # TEXT
    #       mx:    answer.select { |r| r.type == 'MX' },       # Mail Exchange
    #       cname: answer.select { |r| r.type == 'CNAME' },    # Canonical Name
    #       # tsig:  answer.select { |r| r.type == 'TSIG' },     # Transaction Signature
    #       srv:   answer.select { |r| r.type == 'SRV' },      # Service Record
    #       hinfo: answer.select { |r| r.type == 'HINFO' },    # Host Information
    #       axfr:  answer.select { |r| r.type == 'AXFR' },     #
    #       ixfr:  answer.select { |r| r.type == 'IXFR' },
    #   }
    end
    
    #
    # get_domainname gets the domain name of the current record object
    # that has been generated usually by {Core#get_record_object} method
    #
    # @example:
    #   records_objects = get_records_objects(domain)
    #   get_domainname(records_objects)
    #
    # @param [Array<Dnsruby::RR::IN::NS>]
    #
    # @return [Array<String>]
    #
    def get_domainname
      ns_record_obj = @records_objects[:ns]
      
      if ns_record_obj.is_a? Array
        ns_record_obj.map(&:domainname).map(&:to_s).sort
      else
        [ns_record_obj.domainname.to_s]
      end
    end
    # An alias for {Core#get_domainname} method
    alias_method :get_domainnams, :get_domainname
    # An alias for {Core#get_domainname} method
    alias_method :domainnames, :get_domainname

    #
    # get_ip gets all possible IPs assigned with the given domain
    #
    # @param [String] domain the domain name to get it's IP
    # @param [Boolean] v6_included in-case including IPv6 addresses is wanted [Default: false]
    #
    # @return [Array<String>] returns all IPs that's assigned with the given domain
    #
    def get_ip(domain, v6_included=false)
      query_a    = @core.query(domain, 'A')
      query_aaaa = @core.query(domain, 'AAAA') if v6_included
      answer = query_a.answer
      answer << query_aaaa.answer if v6_included
      ips = []
      answer.flatten.each do |ans|
        ips << ans.address.to_s unless ans.type == 'RRSIG' or ans.type == 'CNAME'
      end

      ips
    end
    
    #
    # host_ip_hash gets all all IPs that's assigned with the given domain,
    # then assign it to that domain in a Hash
    #
    # @param [String] domain
    #
    # @return [Hash{String => Array}]
    #
    def host_ip_hash(domain)
      { domain => get_ip(domain) }
    end

    #
    # get_ptr gets all possible PTR records for the given IP address
    #
    # @param [String] domain_addr takes domain or address
    #
    # @return [Array<String>]
    #
    def get_ptr(domain_addr)
      begin
        query = @core.query(domain_addr, 'PTR', 'IN')

        if query.header.ancount >= 1 # {Dnsruby::Header#ancount} returns the number of records in the answer section of the message
          answer = query.answer
          return answer.map {|ans| ans.domainname.to_s}
        else
          return nil
        end
        
      rescue Dnsruby::NXDomain
        # puts '[!] Dnsruby::NXDomain: Domain not exist!'
        return nil
      end
      
    end
    # An alias for {Core#get_ptr} method
    alias_method :ptr, :get_ptr
    
    #
    # zone_transfer get the zone transfer domain for the given domain
    #
    # @param [String] domain
    #
    # @return [Array<String>] return an array of domains that got transferred to
    #
    def get_zone_transfer(domain)
      # if zone_transfer_enabled? domain
        get_records_objects(domain)[:ns]
        zt = Dnsruby::ZoneTransfer.new
        zt.server = get_domainname
        transfer = zt.transfer(domain)
        transfer.map {|r| r.name.to_s}.uniq unless transfer.nil?    # FIXME: NOT ALL RECORDS INCLUDED BECAUSE OF .name
      # else
      #   puts "[!] No zone transfer for #{domain}"
      # end
    end
    # An alias for {Core#get_ptr} method
    alias_method :zone_transfer, :get_zone_transfer
    
    
    private
    
    #
    # is_ip? checks whether the given string is an IP or not
    #
    # @return [Boolean] return the ip
    #
    def is_ip?(str)
      
      ipv4 = IPAddr.new(str).ipv4? rescue $!.class == TypeError   # Rescue if not expected type
      ipv6 = IPAddr.new(str).ipv6? rescue $!.class == TypeError   # Rescue if not expected type
      
      ipv4 or ipv6 ? true : false
      
    end
    
    #
    # zone_transfer_enabled? checks if Zone Transfer is enables
    #
    # @param [String] domain
    # FIXME: still querying ptr ??
    #
    def zone_transfer_enabled?(domain)
      query  = @core.query(domain, 'PTR', 'IN')
      header = query.header

      begin
        true unless header.ancount > 1
      rescue Dnsruby::NXDomain
        false
      end
    end
    
  end
end
end


#
# Usage example
#
if __FILE__ == $0
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
end
