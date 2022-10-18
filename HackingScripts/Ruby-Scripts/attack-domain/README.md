# Attack::Domain (Under heavy development)
[![travis-cli](https://api.travis-ci.org/TechArchSA/attack-domain.svg)](https://travis-ci.org/TechArchSA/attack-domain/) [![Code Climate](https://codeclimate.com/github/TechArchSA/attack-domain/badges/gpa.svg)](https://codeclimate.com/github/TechArchSA/attack-domain) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/8c81748967664cc5bb92147581fb6802)](https://www.codacy.com/app/king-sabri/attack-domain?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=TechArchSA/attack-domain&amp;utm_campaign=Badge_Grade)  [![inch-ci](https://inch-ci.org/github/TechArchSA/attack-domain.svg?branch=master)](https://inch-ci.org/github/TechArchSA/attack-domain)

## DESCRIPTION:
It's a wrapper module for all DNS related tasks. 

## Installation

Install it using `gem` command (not yet pushed to rubygem)

```
gem install attack-domain
```

## Requirements

* Ruby 2.x
* Run-time Dependencies:
  * [Dnsruby](https://github.com/alexdalitz/dnsruby) — an intelligent, pure Ruby, WHOIS client and parser
  * [Whois](https://github.com/weppos/whois) — a feature-complete DNS(SEC) client for Ruby
* Development dependencies (not required for installing the gem):
  * [Bundler](http://bundler.io/) — creating the stable build environment
  * [Rake](https://rubygems.org/gems/rake) — building the package
  * [Yard](http://yardoc.org/) — the documentation
  * [RSpec](https://relishapp.com/rspec/) — additional Ruby Spec test files
  * [awesome_print](https://github.com/awesome-print/awesome_print) — Pretty print your Ruby objects with style

## Usage

* **Core**
```ruby
require 'attack-domain'
require 'pp'

domain1 = 'techarch.com.sa'
domain2 = 'zonetransfer.me'
domain3 = 'owa.zonetransfer.me'
domain4 = 'rubyfu.net'
domain5 = 'wikipedia.org'
ptr_ip1 = '54.221.226.67'    # rubyfu.net
ptr_ip2 = '207.46.197.32'    # owa.zonetransfer.me
ptr_ip3 = '91.198.174.192'   # wikipedia.org


core = Attack::Domain::Core.new
core.setup(nameserver: ['8.8.8.8', '8.8.4.4'], recurse: true, dnssec: false)
puts "[+] get_records_objects(domain)"
pp core.get_records_objects(domain3)

puts "\n[+] get_domainname"
pp core.get_domainname

puts "\n[+] get_ptr(domain_addr)"
pp core.get_ptr(ptr_ip1)
# pp core.get_ptr(ptr_ip2)
pp core.get_ptr(domain2)
pp core.get_ptr(domain4)

puts "\n[+] zone_transfer(domain)"
core.get_records_objects(domain2)
pp core.zone_transfer(domain2)
```

## Development

```
$ git clone https://github.com/TechArchSA/attack-domain.git
$ cd attack-domain
$ bundle install
```


### Testing

```
$ cd attack-domain
$ rspec spec/attack/domain/core_spec.rb --color
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/attack-domain. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.