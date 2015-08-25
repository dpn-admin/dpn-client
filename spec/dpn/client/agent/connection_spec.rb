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

  it "calls the provided block" do
    expect{ |probe|
      connection.paginate(url, query, page_size, &probe)
    }.to yield_control
  end

  it "yields the response" do
    counter = 0
    connection.paginate(url, query, page_size) do |response|
      expect(response.body.to_json).to eql(bodies[counter])
      expect(response.status).to eql(stubs[counter].response.status[0])
      counter += 1
    end
  end

end


describe DPN::Client::Agent::Connection do
  before(:all) { WebMock.enable! }
  let(:connection) { DPN::Client::Agent.new(api_root: API_ROOT, auth_token: "some_auth_token") }

  it "isn't allowed unstubbed requests" do
    expect {
      connection.get(url)
    }.to raise_error ::WebMock::NetConnectNotAllowedError
  end

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

    [{}, { a: "foo", b: "bar" }].each do |query_params| # WebMock breaks if we supply an array here.
      context "with query==#{query_params}" do          # We don't bother because we tested it in GET
        context "with one successful page" do
          let!(:query) { query_params }
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
            [] << stub_request(:get, url).with(query: query.merge({page: 1, page_size: 25}))
                    .to_return(body: bodies[0], status: 200, headers: headers)
          }

          it_behaves_like "pagination"

        end # with one page

        context "with many successful pages" do
          let!(:query) { query_params }
          let!(:page_size) { 1 }
          let!(:bodies) {[
            {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]}.to_json,
            {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]}.to_json,
            {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}.to_json
          ]}
          let!(:headers) { {content_type: "application/json"} }
          let!(:stubs) {
            [
              stub_request(:get, url).with(query: query.merge({page: 1, page_size: 1}))
                .to_return(body: bodies[0], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 2, page_size: 1}))
                .to_return(body: bodies[1], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 3, page_size: 1}))
                .to_return(body: bodies[2], status: 200, headers: headers)
            ]
          }

          it_behaves_like "pagination"
        end

        context "with one failed page" do
          let!(:query) { query_params }
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
            [] << stub_request(:get, url).with(query: query.merge({page: 1, page_size: 25}))
                    .to_return(body: bodies[0], status: 400, headers: headers)
          }

          it_behaves_like "pagination"
        end

        context "with two successful then one failed pages" do
          let!(:query) { query_params }
          let!(:page_size) { 1 }
          let!(:bodies) {[
            {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]}.to_json,
            {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]}.to_json,
            {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}.to_json
          ]}
          let!(:headers) { {content_type: "application/json"} }
          let!(:stubs) {
            [
              stub_request(:get, url).with(query: query.merge({page: 1, page_size: 1}))
                .to_return(body: bodies[0], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 2, page_size: 1}))
                .to_return(body: bodies[1], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 3, page_size: 1}))
                .to_return(body: bodies[2], status: 400, headers: headers)
            ]
          }

          it_behaves_like "pagination"
        end

        context "with a response that changes the page size" do
          let!(:query) { query_params }
          let!(:page_size) { 25 } # primary change
          let!(:bodies) {[
            {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]}.to_json,
            {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]}.to_json,
            {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}.to_json
          ]}
          let!(:headers) { {content_type: "application/json"} }
          let!(:stubs) {
            [
              stub_request(:get, url).with(query: query.merge({page: 1, page_size: 25}))
                .to_return(body: bodies[0], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 2, page_size: 1}))
                .to_return(body: bodies[1], status: 200, headers: headers),
              stub_request(:get, url).with(query: query.merge({page: 3, page_size: 1}))
                .to_return(body: bodies[2], status: 400, headers: headers)
            ]
          }

          it_behaves_like "pagination"
        end

      end
    end


  end

end
