
if __FILE__ == $0
  # $LOAD_PATH.unshift Dir.glob("#{File.dirname __FILE__}/../..").join
  # puts $LOAD_PATH
end
require 'spec_helper'

describe Attack::Domain::Core do
  
  context '[+] Initial Tests' do
    it '[-] has a version number' do
      output = Attack::Domain::VERSION
      expect(output).not_to be nil

      outputs(output)
    end
    
    it '[-] SSSSSSS' do
      
    end
    
  end
     
  before(:context) do
    @core  = Attack::Domain::Core.new
    @domain1   = 'wikipedia.org'
    @domain2   = 'rubyfu.net'
    @domain3   = 'techarch.com.sa'
    @domain4   = 'zonetransfer.me'
    @ptr_ip1   = '91.198.174.192'     # wikipedia.org
    @ptr_ip2   = '207.46.197.32'      # Very Long PTR (owa.zonetransfer.me)
    @ptr_ip3   = '191.239.213.197'    # No PTR
  end
  
  context '[+] Methods Tests' do
    
    it '[-] Can #get_records_objects' do
      @records_objects = @core.get_records_objects(@domain2)
      output = @records_objects
      expect(output).to be_a(Hash)

      outputs(output)
    end

    it '[-] Can #get_domainname' do
      @core.get_records_objects(@domain1)
      expect(@core.get_domainname).to match_array ["ns0.wikimedia.org", "ns1.wikimedia.org", "ns2.wikimedia.org"]
    end
    
    it '[-] has #get_domainname aliases' do
      
      output1 = @core.get_domainnams
      output2 = @core.domainnames
      expect(output1).to match_array ["ns0.wikimedia.org", "ns1.wikimedia.org", "ns2.wikimedia.org"]
      expect(output2).to match_array ["ns0.wikimedia.org", "ns1.wikimedia.org", "ns2.wikimedia.org"]
      
      outputs(output1)
    end
    
    it '[-] Can #get_ptr from an IP' do
      output = @core.get_ptr(@ptr_ip1)
      expect(output).to match_array ["text-lb.esams.wikimedia.org"]

      outputs(output)
    end
    
    it '[-] Can #get_ptr from a domain' do
      output = @core.get_ptr(@domain2)
      expect(output).to match_array ["www.gitbooks.io", "toyama-8522.herokussl.com", "elb072082-1780125795.us-east-1.elb.amazonaws.com"]

      outputs(output)
    end

    it '[-] Can #get_ptr know if no PTR (return nil)' do
      output = @core.get_ptr(@ptr_ip3)
      expect(output).to be_nil

      outputs(output)
    end

    it '[-] Can #get_zone_transfer' do
      output = expect(@core.get_zone_transfer(@domain4)).to be_an Array
      
      outputs(output)
    end

    it '[-] has #get_zone_transfer aliases' do
      output = expect(@core.zone_transfer(@domain4)).to be_an Array
      
      outputs(output)
    end
    
    it '[-] Can #get_zone_transfer know if no zone transfer (return nil)' do
      @core.get_records_objects(@domain2)
      output = @core.zone_transfer(@domain2)
      expect(output).to be_nil

      outputs(output)
    end

  end
  
  
end
