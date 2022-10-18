# encoding: UTF-8

=begin

  Author  : KING SABRI -
  Twitter : @KINGSABRI
  Email   : king \x2e sabri \x40 gmail \x2e com
  This project is released under the GPL 3 license.

=end

module SQLiBrowser

  class Options
    attr_accessor :core
    attr_accessor :browser
    attr_accessor :sqli

    def initialize
      @core    = CoreOptions.new
      @browser = BrowserOptions.new
      @sqli    = SQLiOptions.new
      @utils   = UtilsOptions.new

    end

  end

end