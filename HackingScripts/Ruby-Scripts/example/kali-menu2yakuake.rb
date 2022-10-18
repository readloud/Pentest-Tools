#!/usr/bin/env ruby
#
# For *Yakuake* lovers, Small scrip to make kali command-line applications
# open directly in Yakuake and change default tab title to be the command name.
# For more info about contorlling yakuake: http://king-sabri.net/?p=2388
# KING SARBRI | @KINGSABRI

class String
  def red; colorize(self, "\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def bold; colorize(self, "\e[1m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end


def backup(folder)
  _folder = folder.rpartition("/").first
  zip = _folder.split("/")[1..-2].join("_")
  puts "[!] ".green + "Zipping '#{_folder}' folder."
  sleep 0.5
  system("cp -a #{_folder} #{zip}")
  system("tar -czf #{zip}.tar.gz #{zip}")
  puts "[+] ".green + "Zipped file name: '#{zip}.tar.gz' in '#{Dir.pwd}/' directory."
  sleep 0.8
end

#
# Find the command from menu file. @return [Hash]
#
def kali_app_desktop(file)
  file = File.read(file)
  
  bash = file.match(/sh.*-bash.*/i).to_s  #=> "sh -c \"aircrack-ng --help;${SHELL:-bash}\""
  
  cmd = bash.match(/["|'].*;/i).to_s.to_s.gsub(/[\"|;]/,'')  #=> "aircrack-ng --help"
  
  tab = bash.match(/["|'].*;/i).to_s.gsub(/[\"|;]/,'').split.first	#=> "aircrack-ng"
  
  return { :tab => tab, :cmd => cmd } 
end

#
# Change menu file content to ours
#
def change_contents(file_list)

  list_size = file_list.size
  puts "\n[+] ".green + "Number of files: " + "#{list_size}".bold
  sleep 0.8

  file_list.each do |file|     

    menu = kali_app_desktop(file)  
    
    final_menu =  "qdbus org.kde.yakuake /yakuake/sessions addSession; SID=`qdbus org.kde.yakuake /yakuake/sessions activeSessionId`;qdbus org.kde.yakuake /yakuake/tabs setTabTitle $SID #{menu[:tab]};qdbus org.kde.yakuake /yakuake/sessions runCommand '#{menu[:cmd]}'"

    contents = File.read(file)
    next if contents.match(/sh.*-bash.*/i).to_s.empty?
    
    new_contents = contents.gsub("#{contents.match(/sh.*-bash.*/i).to_s}" , final_menu)

    f = File.new(file, 'w')
    f.write(new_contents)    
    f.close
    
    puts "#{file.split("/").last}".bold + "\t\t\t\t" + "[ " + "Done".green + " ]"
  end
  puts "[+] ".green + "Done!\n\n"
end



if Process.uid != 0
  puts "[+] ".red + "You MUST run as root.\n\n"
  exit
end


path1 = "/usr/share/kali-menu/applications/kali*.desktop"
path2 = "/usr/share/applications/kali*.desktop"
[path1,path2].each {|path| backup(path)}

file_list = [Dir.glob(path1), Dir.glob(path2)]
file_list.each do |list|
  change_contents(list)
end





