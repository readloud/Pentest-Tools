# encoding: UTF-8

=begin

  Author  : KING SABRI -
  Twitter : @KINGSABRI
  Email   : king \x2e sabri \x40 gmail \x2e com
  This project is released under the GPL 3 license.

=end

module SQLiBrowser

  class CoreOptions
    attr_accessor :version
    attr_accessor :verbose
    attr_accessor :update
    attr_accessor :save_output
    def initialize
      @version     = SQLiBrowser::VERSION
      @verbose     = false
      @update      = false
      @save_output = nil
    end

  end

end