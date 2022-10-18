#!/usr/bin/env ruby
# 
# gem install geoip
# Download the geoip database from http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# wget -c http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# gunzip GeoLiteCity.dat.gz
# http://dev.maxmind.com/geoip/legacy/geolite/
#

require 'geoip'
gem 'maxmind-geoip2'
#
# colors
# 
class String
    def red; colorize(self, "\e[1m\e[31m"); end
    def green; colorize(self, "\e[1m\e[32m"); end
    def dark_green; colorize(self, "\e[32m"); end
    def yellow; colorize(self, "\e[1m\e[33m"); end
    def blue; colorize(self, "\e[1m\e[34m"); end
    def dark_blue; colorize(self, "\e[34m"); end
    def pur; colorize(self, "\e[1m\e[35m"); end
    def bold; colorize(self, "\e[1m"); end
    def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end


begin
	ip = ARGV[0].match(/^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/).to_s
	
	geoip = GeoIP.new('GeoLiteCity.dat')
	geoinfo = geoip.country(ip).to_hash
	# puts "\n----------------------------------------"
	puts "IP address:\t".bold   + "#{geoinfo[:ip]}".blue
	puts "Country:\t".bold      + "#{geoinfo[:country_name]}".blue
	puts "Country code:\t".bold + "#{geoinfo[:country_code2]}".blue
	puts "City name:\t".bold    + "#{geoinfo[:city_name]}".blue
	puts "Latitude:\t".bold     + "#{geoinfo[:latitude]}".blue
	puts "Longitude:\t".bold    + "#{geoinfo[:longitude]}".blue
	puts "Time zone:\t".bold    + "#{geoinfo[:timezone]}".blue
	# puts "----------------------------------------\n"
rescue
	usage = "ruby ip2location.rb IP-ADDRESS\nex. ruby ip2location.rb 173.194.39.227"
	puts "#{usage}\n" if ip.nil? or ip.empty? 
	
	puts "\n1. make sure 'GeoLiteCity.dat' file in the same path >> Hardcoded" 
	puts "2. make sure you put a valid IP."
end
