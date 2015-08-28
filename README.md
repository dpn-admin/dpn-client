# DPN::Client

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dpn-client' :git => 'https://github.com/dpn-admin/dpn-client.git'

```

And then execute:

    $ bundle install

## Usage

See the
[yard documentation](http://www.rubydoc.info/github/dpn-admin/dpn-client/master/DPN/Client/Agent)
for more info, but the basics are thus:

```ruby
client = DPN::Client.client.configure do |c|
  c.api_root = "https://hathitrust.org/api_root"
  c.auth_token = "auth_token_for_hathi"
end

client.bags(page_size: 25, admin_node: "hathi") do |bag|
  bag.inspect # this block is optional
end

resp = client.create_bag(some_bag_hash)
if resp.success?
  some_bag_hash[:status] = resp[:status]
end
```

Essentially, single-endpoint operations always return a Response object,
but you can treat this object as just a hash, if you want.  Index operations
return an array of hashes.

You can pass a block to any operation.  For single-endpoints, the response will
be passed to the block.  For indexes, each individual result will be passed 
successively to the block. Using blocks is recommended.

## License

Copyright (c) 2015 The Regents of the University of Michigan.  
All Rights Reserved.  
Licensed according to the terms of the Revised BSD License.  
See LICENSE.md for details.  

