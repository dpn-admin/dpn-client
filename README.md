# DPN::Client


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dpn-client' :git => 'https://github.com/dpn-admin/dpn-client.git'

```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dpn-client

## Usage

See the
[[yard documentation]](http://www.rubydoc.info/github/dpn-admin/dpn-client/master/DPN/Client/Agent)
for more info, but the basics are thus:

```ruby
client = DPN::Client.client.configure do |c|
  c.api_root = "https://hathitrust.org/api_root"
  c.auth_token = "auth_token_for_hathi"
end

client.bags(page_size: 25, admin_node: "hathi) do |bag|
  bag.inspect # this block is optional
end

resp = client.create_bag(some_bag_hash)
if resp.success?
  some_bag_hash[:status] = resp[:status]
end
```

## License

Copyright (c) 2015 The Regents of the University of Michigan.  
All Rights Reserved.  
Licensed according to the terms of the Revised BSD License.  
See LICENSE.md for details.  

