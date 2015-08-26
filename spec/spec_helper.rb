# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'bundler/setup'
#Bundler.setup
Bundler.require

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dpn/client'

require 'httpclient'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: false)
WebMock.disable!

def test_api_root
  "https://test.client.dpn.org"
end

def dpn_url(url)
  url, query = url.split("?")
  api_string = "api-v#{DPN::Client::api_version}"
  if query
    File.join test_api_root, api_string, url, "/?#{query}"
  else
    File.join test_api_root, api_string, url, "/"
  end
end


require "helpers/single_endpoint"
require "helpers/paged_endpoint"