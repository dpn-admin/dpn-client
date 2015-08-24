# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

API_ROOT = "https://api.test.dpn-client.org/"

shared_examples "basic http" do |operation|
  url = File.join API_ROOT, "/"
  let(:body) { {tag: "content" } }
  before(:each) do
    @request = stub_request(:get, url)
                   .to_return(body: body.to_json, status: 200, headers: {content_type: "application/json"})
  end

  it "queries #{url}" do
    connection.public_send(operation, url)
    expect(@request).to have_been_requested
  end

  it "returns the correct response object" do
    response = connection.public_send(operation, url)
    expect(response).to be_a DPN::Client::Response
    expect(response.body).to eql(body)
  end

  it "executes the passed block on the response" do
    expect{ |probe|
      connection.public_send(operation, url, &probe)
    }.to yield_with_args(DPN::Client::Response)
  end

  it "handles query parameters" do
    real_query = "a=1,2,3&b=foo"
    @request.with(query: real_query)

    connection.public_send(operation, url, { a: [1,2,3], b: "foo" } )

    expect(@request).to have_been_requested
  end

  it "returns errors" do
    error_url = File.join url, "error", "/"
    stub_request(:get, error_url).to_return(body: body.to_json, status: 400)

    response = connection.public_send(operation, error_url)

    expect(response).to be_a DPN::Client::Response
    expect(response.status).to eql(400)
  end
end


describe DPN::Client::Agent::Connection do
  before(:all) { WebMock.enable! }
  let(:connection) { DPN::Client::Agent.new(api_root: API_ROOT, auth_token: "some_auth_token") }

  describe "#get" do
    it_behaves_like "basic http", :get
  end

  describe "#post" do
    it_behaves_like "basic http", :get
  end





end