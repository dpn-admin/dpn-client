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

```
client = DPN::Client.new("https://some.node/api_root", my_auth_token)
client.get("/node") # It will automatically add this to the api root and api version.
client.get("https://google.com") # but if you supply a full url, it will do this instead.
```
