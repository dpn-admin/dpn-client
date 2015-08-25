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

shared_examples "a dpn-client method" do |method, *args|
  # expect stub to be defined with let!

  it "sends the right request" do
    agent.public_send(method, *args)
    expect(stub).to have_been_requested
  end

  it "returns a response" do
    response = agent.public_send(method, *args)
    expect(response).to be_a DPN::Client::Response
    expect(response.to_json).to eql(stub.response.body)
  end

  it "calls the block" do
    expect { |probe|
      agent.public_send(method, *args, &probe)
    }.to yield_with_args(be_a(DPN::Client::Response))
  end

  it "yields the response" do
    agent.public_send(method, *args) do |response|
      expect(response.status).to eql(stub.response.status[0])
      expect(response.to_json).to eql(stub.response.body)
    end
  end
end