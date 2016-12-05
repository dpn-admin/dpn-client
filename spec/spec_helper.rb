# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'bundler/setup'
Bundler.require
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dpn/client'

require 'httpclient'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: false)
WebMock.disable!

def test_api_root
  @test_api_root ||= "https://test.client.dpn.org"
end

def test_api_ver
  @test_api_ver ||= "api-v#{DPN::Client.api_version}"
end

def test_api_url
  @test_api_url ||= File.join test_api_root, test_api_ver
end

def dpn_path(url)
  url.sub!(test_api_root,'')
  url.sub!(test_api_ver, '')
  if url.include?('?')
    url, query = url.split('?')
    File.join url.to_s, "?#{query}"
  else
    File.join url, '/'
  end
end

def dpn_url(url)
  path = dpn_path(url)
  File.join test_api_url, path
end

require "helpers/single_endpoint"
require "helpers/paged_endpoint"
