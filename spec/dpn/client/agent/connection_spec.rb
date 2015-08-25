# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

API_ROOT = "https://api.test.dpn-client.org/"
url = File.join API_ROOT, "/"

shared_examples "basic http" do |operation, *args|
  let(:body) {  {tag: "content" } }
  before(:each) do
    @request = stub_request(operation, url)
                   .to_return(body: body.to_json, status: 200, headers: {content_type: "application/json"})
  end

  it "requests #{url}" do
    connection.public_send(operation, url, *args)
    expect(@request).to have_been_requested
  end

  it "returns the correct response object" do
    response = connection.public_send(operation, url, *args)
    expect(response).to be_a DPN::Client::Response
    expect(response.body).to eql(body)
  end

  it "executes the passed block on the response" do
    expect{ |probe|
      connection.public_send(operation, url, *args, &probe)
    }.to yield_with_args(DPN::Client::Response)
  end

  it "returns errors" do
    error_url = File.join url, "error", "/"
    stub_request(operation, error_url).to_return(body: body.to_json, status: 400)

    response = connection.public_send(operation, error_url, *args)

    expect(response).to be_a DPN::Client::Response
    expect(response.status).to eql(400)
  end
end


describe DPN::Client::Agent::Connection do
  before(:all) { WebMock.enable! }
  let(:connection) { DPN::Client::Agent.new(api_root: API_ROOT, auth_token: "some_auth_token") }

  describe "#get" do
    it_behaves_like "basic http", :get, nil

    it "handles query parameters" do
      real_query = "a=1,2,3&b=foo"
      stub = stub_request(:get, url).with(query: real_query)
        .to_return(body: "{}", status: 200, headers: {content_type: "application/json"})

      connection.get(url, { a: [1,2,3], b: "foo" } )

      expect(stub).to have_been_requested
    end
  end

  describe "#post" do
    it_behaves_like "basic http", :post, { foo: "bar" }.to_json
  end

  describe "#put" do
    it_behaves_like "basic http", :put, { foo: "bar" }.to_json
  end

  describe "#delete" do
    it_behaves_like "basic http", :delete
  end

  describe "#paginate" do
    context "with only one page" do
      let(:headers) { {content_type: "application/json"} }
      let(:body) {
        {
          count: 1,
          next: nil,
          previous: nil,
          results: [
            { foo: "bar" }
          ]
        }.to_json
      }

      before(:each) do
        @stub = stub_request(:get, url).with(query: {page: 1, page_size: 25})
                 .to_return(body: body, status: 200, headers: headers)
      end

      it "requests #{url}?page=1&page_size=25" do
        connection.paginate(url, {}, 25) {}
        expect(@stub).to have_been_requested
      end

      it "handles query parameters" do
        real_query = { a: "1,2,3", b: "foo", page: 1, page_size: 25}
        stub = stub_request(:get, url).with(query: real_query)
                 .to_return(body: body, status: 200, headers: headers)

        connection.paginate(url, { a: [1,2,3], b: "foo" }, 25 ) {}

        expect(stub).to have_been_requested
      end

      # it "returns the correct response object" do
      #   response = connection.paginate( url, *args)
      #   expect(response).to be_a DPN::Client::Response
      #   expect(response.body).to eql(body)
      # end

      it "passes the results array to the passed block" do
        expect{ |probe|
          connection.paginate(url, {}, 25, &probe)
        }.to yield_with_args( [{foo: "bar"}] )
      end

    end # context "with only one page"
  end





end