# getCabrito
Email open &amp; click tracking server for [goCabrito](https://github.com/KINGSABRI/goCabrito). It works extactly similar to marketing emails. It detects the uniqly generated URLs for each sent email. In nutshell, it's like goPhish tracking opens and clicks to give statistics however getCabrito is not a full solution like goPish it just tracks and save the tracks in a sqlite database.

The script takes a sqlite database generate by goCabrito. The generate database (by goCabrito) contains all the users that have been tracked by injecting one or more of the tracking tags {{track-open}} or {{track-click}}.

Once the tracking URL is visited, it maps the hash from the URL with current database records. It then update the database with the required information such as: 
- click_at
- click_count
- open_at
- open_count
- user_agent
- ip_addr
- loots (submitted data if any POST request)

Although getCabrito updates the given database with the above collected data, it writes in `visits.log` file for debugging

```
{"target_id"=>2, "email"=>"user2@example.com", "hash"=>"251d01e26c5aada16a6d713b4de70bb89ff3298f", "session"=>"1bb38e017d5f72905d8fc6964e271b5f94f0cbc6c997e862fad646e87e05c3ec", "click_at"=>"2021-06-21 09:10:56 +0300", "open_at"=>"2021-06-21 09:10:56 +0300", "user_agent"=>"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36", "ip_addr"=>"", "click_count"=>5, "open_count"=>1}: 
{"loot_id"=>27, "loot"=>"user2@example.com", "target_id"=>2}: 
```


**Note:** I've added some queries that might help you to generate some statistics after you finish your campagin(s). 

All what you need to do is after/during the campagin, you run these scripts against the sqlite database you have get some numbers
- number of clicks
- number of opens
- data submitted 
- vistis 


```
ruby queries/read-sql.rb sql.db
```

```
ruby queries/statistics.rb sql.db
```

result
```
--> Open count
4
--> Click count
26
--> Known
3
--> Unkown
14
--> Submitted
32
```

## Installation 
```
apt-get install build-essential libsqlite3-dev sqlite3
```

```
gem install sinatra rerun sqlite3
```

```
rerun 'ruby getCabrito.rb sql.db'
```


## How to use?
Setup nginx to work as reverse proxy to forward requests to getCabrito script. The setup is identical to [creds-harvester](https://github.com/KINGSABRI/creds-harvester) as it work mostly like it in addition to the tracking part.


#### Step #1
Put your cloned website under `views` directory

#### Step #2 
Find the input id from within the cloned login form you want to use (case sensitive).
Example: 
```html
<!DOCTYPE html>
<html>
<body>

<h2>HTML Forms</h2>

<form action="/login">
  Username:<br>
  <input type="text" id="UserName" name="User">
  <br>
  Password:<br>
  <input type="password" id="Password" name="Pass">
  <br><br>
  <input type="submit" value="Submit">
</form> 

</body>
</html>
```

- Parameter id for user is: UserName
- Parameter id for pass is: Password
- Change the "Action" attributes to be `"/login"`  as of we have in the getCabrito.rb file. (you can change the route `/login` to anything but make sure that you edit it in the HTML too)
#### Step #3
Go edit `getCabrito.rb` script and add the parameter ID's as there are in the HTML form
```ruby
username = params['Username']
password = params['Password']
```

**The Main page**

Specify the main page file from within `views` directory. No need to include views directory as it's already included.

```ruby
erb 'PATH/TO/LOGIN_PAGE'.to_sym
```

**Redirect 404**

You can redirect the users to the main page if visited not found pages
```ruby
not_found do
  redirect '/'.to_sym
end
```

**Redirect after submitting**

Also, you can redirect the users once they submit their credentials to the cloned website or other of your choice.
```ruby
redirect 'https://google.com'
```

#### Step #4
Run the script as following 

```
rerun 'ruby getCabrito.rb'
```

#### Step #5 (optional - recommended)
Sometime the phishing website is just a small part of many websites on the server. 

If you want to run it with nginx, you can make nginx as reverse proxy for the application. 

1. Run the script (Step #4)

2. Configure nginx 

```
nano /etc/nginx/sites-available/example.com.conf
```
Then add the following and restart nginx service.

```
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
    location / {
      proxy_pass       http://localhost:8181;
      proxy_set_header Host      $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
}
```

