#!/usr/bin/env ruby
#
# Simple queries to read data from the database 
#
require 'sqlite3'


@db_sql = SQLite3::Database.open(ARGV[0])
@db_sql.results_as_hash = true

# pp @db_sql.table_info("targets")

# @db_sql.execute( "select * from targets" ) do |row|
#   p row
# end

puts "--- [targets table]"
pp @db_sql.execute( "select * from targets" )
puts "--- [loots table]"
# pp @db_sql.execute( "select * from loots" )

puts "\n\n--- [relational]-----------------------------"
query = <<-SQL
    SELECT
      targets.target_id,
      targets.email,
      targets.hash, 
      targets.click_at,
      targets.click_count,
      targets.open_at,
      targets.open_count,
      loots.loot
    FROM
      targets
    INNER JOIN
      loots
    ON
      loots.target_id = targets.target_id
SQL

# pp @db_sql.execute(query)
puts "-----------------------------"

query = <<-SQL
    SELECT
      loots.loot
    FROM
      targets
    INNER JOIN
      loots
    ON
      loots.target_id = targets.target_id
    WHERE
      loots.loot NOT NULL;
SQL

pp res = @db_sql.execute(query)
pp res.size 
pp res.uniq.size 

qry_opens     = "SELECT SUM(open_count) FROM targets;"
qry_clicks    = "SELECT SUM(click_count) FROM targets;"
qry_known     = "SELECT COUNT(email) FROM targets;"
qry_unknown   = "SELECT COUNT(session) FROM targets WHERE email IS NULL;"
qry_submitted = "SELECT COUNT(loot) FROM loots;"

puts "--> Open count"
pp opens     = @db_sql.get_first_value(qry_opens)
puts "--> Click count"
pp clicks    = @db_sql.get_first_value(qry_clicks)
puts "--> Known"
pp known     = @db_sql.get_first_value(qry_known)
puts "--> Unkown"
pp unknown   = @db_sql.get_first_value(qry_unknown)
puts "--> Submitted"
pp submitted = @db_sql.get_first_value(qry_submitted)




# p @db_sql.execute <<-SQL
#     SELECT * FROM targets
#     WHERE hash='#{hash}';
# SQL

# query1 = "SELECT * FROM targets WHERE hash = ?;"
# p @db_sql.get_first_row(query1, hash)

# query2 = <<-SQL
#     UPDATE 
#       targets
#     SET 
#       click_at = "1111",
#       open_at = "2222",
#       user_agent = "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN",
#       ip_addr = "192.168.100.100",
#       click_count = 3,
#       open_count = 2
#     WHERE 
#       hash='#{hash}';
# SQL
# # @db_sql.execute(query2)
# puts "---"


# p @db_sql.get_first_row(query1, hash)

# puts "-click count--"
# p @db_sql.get_first_value("SELECT click_count FROM targets WHERE hash = ?;", hash)
# 

# @db_sql.execute( "select * from targets" ) do |row|
#   p row
# end


# SELECT DISTINCT
#     loots.loot
#  FROM
#  	targets
# INNER JOIN
# 	loots
# WHERE 
# 	loots.loot NOT NULL

