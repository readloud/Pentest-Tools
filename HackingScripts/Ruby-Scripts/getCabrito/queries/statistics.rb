#!/usr/bin/env ruby
#
# Simple queries to read data from the database and give you charts in terminal 
#
require 'tty-pie' # gem install tty-pie
require 'sqlite3'

@db_sql = SQLite3::Database.open(ARGV[0])
@db_sql.results_as_hash = true

# clear, reset, bold, dark, dim, italic, underline, underscore, inverse, hidden, strikethrough, black, red, green, yellow, blue, magenta, cyan, white, on_black, on_red, on_green, on_yellow, on_blue, on_magenta, on_cyan, on_white, bright_black, bright_red, bright_green, bright_yellow, bright_blue, bright_magenta, bright_cyan, bright_white, on_bright_black, on_bright_red, on_bright_green, on_bright_yellow, on_bright_blue, on_bright_magenta, on_bright_cyan, on_bright_white.


qry_opens       = "SELECT SUM(open_count) FROM targets;"
qry_clicks      = "SELECT SUM(click_count) FROM targets;"
qry_known       = "SELECT COUNT(email) FROM targets;"
qry_unknown     = "SELECT COUNT(session) FROM targets WHERE email IS NULL;"
qry_submitted   = "SELECT COUNT(loot) FROM loots;"
qry_known_sub = <<-SQL
    SELECT DISTINCT
      targets.hash,
      loots.loot
    FROM
      targets
    INNER JOIN
      loots
    ON
      (targets.hash IS NOT NULL) AND (loots.loot IS NOT NULL) 
SQL
#       (targets.email AND targets.hash AND loots.loot) IS NOT NULL

qry_unknown_sub = <<-SQL
SELECT DISTINCT
      targets.hash,
      loots.loot
    FROM
      targets
    INNER JOIN
      loots
    ON
      (targets.hash IS NULL) AND (loots.loot IS NOT NULL)
SQL

pp opens      = @db_sql.get_first_value(qry_opens)
puts '---'
pp clicks     = @db_sql.get_first_value(qry_clicks)
puts '---'
pp known      = @db_sql.get_first_value(qry_known)
puts '---'
pp unknown    = @db_sql.get_first_value(qry_unknown)
puts '---'
pp submitted  = @db_sql.get_first_value(qry_submitted)
puts '---'
pp known_sub  = @db_sql.execute(qry_known_sub)#.map {|v| v["loot"].downcase}.flatten.uniq.size
puts '---'
pp unknown_sub  = @db_sql.execute(qry_unknown_sub)#.map {|v| v.values.compact.first.downcase}.flatten.uniq.size
puts '---'


# data = [
#   { name: "Email Opened",      value: opens,      color: :green,          fill: "*" },
#   { name: "Email Clicked",     value: clicks,     color: :bright_green,   fill: "+" },
#   { name: "Known Receivers",   value: known,      color: :bright_magenta, fill: "@" },
#   { name: "Unknown Receivers", value: unknown,    color: :bright_yellow,  fill: "x" },
#   { name: "Submitted Data",    value: submitted,  color: :red,            fill: "-" }
# ]

# data = [
#   { name: "Email Opened",       value: opens,      color: :green,          fill: "•" },
#   { name: "Email Clicked",      value: clicks,     color: :bright_green,   fill: "◌" },
#   { name: "Known Receivers",    value: known,      color: :bright_magenta, fill: "⤶" },
#   { name: "Unknown Receivers",  value: unknown,    color: :bright_yellow,  fill: "⤷" },
#   { name: "Submitted Data",     value: submitted,  color: :red,            fill: "✹" },
#   { name: "Known submitter",    value: qry_known_sub,  color: :red,            fill: "✹" }
# ]
# pie = TTY::Pie.new(
#   data: data, 
#   radius: 10,
#   legend: {
#     format: "│ %<label>s %<name>s (%<currency>s)"
#   }
# )
# puts pie 



