# encoding: UTF-8

=begin

  Author  : KING SABRI -
  Twitter : @KINGSABRI
  Email   : king \x2e sabri \x40 gmail \x2e com
  This project is released under the GPL 3 license.

=end

module SQLiBrowser

  class BrowserOptions
    attr_accessor :browser
    attr_accessor :proxy
    attr_accessor :proxy_host
    attr_accessor :proxy_port
    attr_accessor :proxy_user
    attr_accessor :proxy_pass

    def initialize
      @browser = "firefox"
      @proxy = false
      @proxy_host = "127.0.0.1"
      @proxy_port = 8080
      @proxy_user = nil
      @proxy_pass = nil
    end
  end

end