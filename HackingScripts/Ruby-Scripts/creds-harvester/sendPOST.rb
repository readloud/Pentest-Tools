#!/usr/bin/env ruby
#
# ruby sendPOST.rb post_file.txt 10 "POST THE STRING WILL APPEAR IF POST SUCCEED"
#
require 'net/http'
require 'uri'


class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def light_red; colorize(self, "\e[1m\e[91m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def dark_green; colorize(self, "\e[32m"); end
  def bold; colorize(self, "\e[1m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

module HTTP
  class PostParser

    attr_reader :post   # The original post
    attr_reader :parse  # Full parsed post (header and body). Can take :headers, :body . @return [Hash]

    def initialize(post)
      @post  = post.dup
      @parse = [:headers => headers , :body => body , :full_post => [headers, body]]
    end

    #
    # Parsing post headers and @return [Hash] of of {header => value}
    #
    def headers
      post = @post
      post_header = post.split("\n")[0] # To solve split(":") issue in POST http://domain.com
      post_header       = post_header.split(" ", 2)

      headers_grep      = post.scan(/(.*:.*)[\n\r]/)

      headers = [{post_header[0] => post_header[1]}]
      headers_grep.map do |h|
        val = h[0].split(":", 2)
        val[1].strip!

        headers << {val[0] => val[1]}
      end

      return headers
    end

    #
    # Parsing post body and @return [Hash] of {variable => value}
    #
    def body
      post = @post
      body = []

      body_grep = post.split(/&/)[1..-1]
      body_grep.map do |var|
        val = var.split("=", 2)
        val[1].chomp if val.last
        val[1].strip!

        body << {val[0] => val[1]}
      end

      return body
    end

  end # PostParser

end # HTTP

post_file   = ARGV[0]
repeat_num  = ARGV[1].to_i
success_str = ARGV[2]

if post_file == nil or repeat_num == nil or success_str == nil
    puts "Usage: ruby sendPOST.rb [POST FILE] [NUMBER OF REPEATING] [SUCCESS STRING]"
    puts 'example: ruby sendPOST.rb post.txt 10 "Thank you for contacting us!"'
    exit
end

post_content = File.read post_file

post = HTTP::PostParser.new post_content
body = post.body.map {|b| "#{b.keys[0]}=#{b.values[0]}"}.join
uri  = URI.parse "http://#{post.headers[1]["Host"]}/#{post.headers[0]["POST"].split[0]}"

repeat_num.times do
    begin
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path)
        request.body = body
        Thread.new{
            response = http.request(request)
            puts "[+] ".green + "#{response.code}".dark_green + " | ".green + "Successful Post".dark_green unless response.body.match("#{success_str}") == nil
        }.join
    rescue Exception => e
        puts "Error #{e}".red
    end
end
