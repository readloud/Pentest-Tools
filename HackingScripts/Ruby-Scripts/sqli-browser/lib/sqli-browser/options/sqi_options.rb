# encoding: UTF-8

=begin

  Author  : KING SABRI -
  Twitter : @KINGSABRI
  Email   : king \x2e sabri \x40 gmail \x2e com
  This project is released under the GPL 3 license.

=end

module SQLiBrowser
  attr_accessor :url
  attr_accessor :cookies
  attr_accessor :param
  attr_accessor :payload
  attr_accessor :data
  # List of common payloads for all database types and references (it can be more intelligence later like take dbms type)
  attr_accessor :dbms
  attr_accessor :cleaning_regex
  attr_accessor :regex
  class SQLiOptions

    def initialize
      @url     = nil
      @cookies = nil
      @para    = nil
      @payload = ""
      @data    = "\r\n"
      @dbms    = :mysql
      @cleaning_regex = "<.*?>"
      @regex   = nil
    end

  end

end