# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

API_ROOT = "https://api.test.dpn-client.org/"

describe DPN::Client::Agent::Connection do
  before(:all) { WebMock.enable! }
  let(:connection) { DPN::Client::Agent.new(api_root: API_ROOT, auth_token: "some_auth_token") }

  describe "#get" do
    url = File.join API_ROOT, "/"
    body = {a: "b"}
    before(:each) do
      @request = stub_request(:get, url)
                  .to_return(body: body.to_json, status: 200, headers: {content_type: "application/json"})
    end

    it "queries #{url}" do
      connection.get(url)
      expect(@request).to have_been_requested
    end

    it "returns the correct response object" do
      response = connection.get(url)
      expect(response).to be_a DPN::Client::Response
      expect(response.body).to eql(body)
    end

    it "executes the passed block on the response" do
      expect{ |probe|
        connection.get(url, &probe)
      }.to yield_with_args(DPN::Client::Response)
    end

    it "handles query parameters" do
      real_query = "a=1,2,3&b=foo"
      @request.with(query: real_query)

      connection.get(url, { a: [1,2,3], b: "foo" } )

      expect(@request).to have_been_requested
    end
  end


  describe "#post" do

  end





end