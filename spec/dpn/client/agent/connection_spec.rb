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


shared_examples "pagination" do
  # query, page_size
  # stubs, bodies

  it "requests all of the stubs" do
    connection.paginate(url, query, page_size) {}
    stubs.each do |stub|
      expect(stub).to have_been_requested
    end
  end

  it "passes the response to the provided block" do
    expect{ |probe|
      connection.paginate(url, query, page_size, &probe)
    }.to yield_with_args( DPN::Client::Response )
  end

  it "yields the correct thing when it yields" do
    counter = 0
    connection.paginate(url, query, page_size) do |response|
      expect(response.body.to_json).to eql(bodies[counter])
      counter += 1
    end
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

    it "requires a block" do
      expect {
        connection.paginate(url, {}, 25)
      }.to raise_error(ArgumentError)
    end

    context "with one page" do
      let!(:query) { {} }
      let!(:page_size) { 25 }
      let!(:bodies) {
        [] << {
          count: 1,
          next: nil,
          previous: nil,
          results: [
            { foo: "bar" }
          ]
        }.to_json
      }
      let!(:headers) { {content_type: "application/json"} }
      let!(:stubs) {
        [] << stub_request(:get, url).with(query: {page: 1, page_size: 25})
                .to_return(body: bodies[0], status: 200, headers: headers)
      }

      it_behaves_like "pagination"

    end # with one page
  end

end
