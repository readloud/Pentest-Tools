# encoding: UTF-8

=begin

  Author  : KING SABRI -
  Twitter : @KINGSABRI
  Email   : king \x2e sabri \x40 gmail \x2e com
  This project is released under the GPL 3 license.

=end

module SQLiBrowser
  VERSION = "0.1.0"
  def banner

    errors =
    {
      "php" => %q{|  You have an error in your SQL syntax;           |
          |  check the manual that corresponds to            |
          |  your MySQL server version for the               |
          |  right syntax to use near ''' at line 1          |},
      "asp" => %q{|  Microsoft SQL Native Client error               |
          |  Unclosed quotation mark '80040e14' after the    |
          |  character string ''. /user.asp, line 9          |
          |                                                  |},
      "jsp" => %q{|  ORA-53044: Invalid Tag:                         |
          |  ORACLE DATABASE 11G ENTERPRISE EDITION          |
          |  RELEASE 11.1.0.7.0 - PRODUCTION                 |
          |                                                  |}
    }.to_a.sample(1).to_h


    %Q{
          +------------------[ SQLi Browser ]----------------+
          | +..............................................+ |
          | | http://vuln-site.com/user.#{errors.keys.first}?id=14'        >| |
          | +..............................................+ |
          +--------------------------------------------------+
          |                                                  |
          |                                                  |
          #{errors.values.first}
          |                                                  |
          |                                                  |
          +---------------------------------Version: #{VERSION}---+

    }

  end
end
