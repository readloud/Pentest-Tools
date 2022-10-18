#!/usr/bin/env ruby
# Simple script to generate all possible mobile numbers for particular GSM provider
# You can use it for Wireless Password/Wireless cracking. 
# All what you need is to mention the GSM key
# assume your are using Mobily provider from KSA so you'll mention 056
# ex. ruby phone-generator.rb 056
# KING SABRI | @KINGSABRI


begin
  key = ARGV[0]
  
  if key.to_i == 0 || key == nil || key.scan(/.{1}/).size > 4
    puts "[!] WTF!,, Enter a valid number for GSM Service provider.\n"
    puts "Usage:"
    puts "ruby #{__FILE__} 062"
    puts "ruby #{__FILE__} 0628"
    exit!
  end
  
  puts "[*] Wait, this will take few minutes...\n"
  
  file = "#{key}-numbers.list"
  File.open(file, 'w') do |file|
      ('0000000'..'9999999').to_a.collect do |num|              # Increase or Decrease the number length based on your needs
        file.puts "#{key}#{num}"
      end
  end
  puts "[+] " + "File name: " + "#{file}."
  puts "[+] " + "File size: " + "#{File.size(file)/1048576} Mb."
rescue Exception => e
  puts "[!] #{e}"
end

