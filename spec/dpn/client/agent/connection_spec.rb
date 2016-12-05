# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

shared_examples "basic http" do |operation, *args|
  let(:body) {  {tag: "content" } }
  before(:each) do
    @request = stub_request(operation, stub_url)
                   .to_return(body: body.to_json, status: 200, headers: headers)
  end

  it "requests a url" do
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
    error_url = File.join(url, "error")
    stub_request(operation, dpn_url(error_url)).to_return(body: body.to_json, status: 400)
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
  let!(:headers) { {content_type: "application/json"} }

  let(:connection) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  let(:url) { 'bag' }
  let(:stub_url) { dpn_url(url) }

  before(:all) { WebMock.enable! }

  it "isn't allowed unstubbed requests" do
    expect {
      connection.get(url)
    }.to raise_error ::WebMock::NetConnectNotAllowedError
  end

  describe "#get" do
    it_behaves_like "basic http", :get, nil

    it "handles query parameters" do
      real_query = "a=1,2,3&b=foo"
      stub = stub_request(:get, stub_url).with(query: real_query)
        .to_return(body: "{}", status: 200, headers: headers)

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
        let(:query) { query_params.merge(page: 1, page_size: page_size) }
        let(:page_size) { 25 } # default, overriden in some contexts

        def stub(query, body, status)
          stub_request(:get, stub_url)
            .with(query: query)
            .to_return(body: body, status: status, headers: headers)
        end

        context "when a query matches one result" do
          let(:bodies) {
            [] << {
              count: 1,
              next: nil,
              previous: nil,
              results: [
                { foo: "bar" }
              ]
            }.to_json
          }

          context "success" do
            let!(:stubs) { [stub(query, bodies[0], 200)] }
            it_behaves_like "pagination"
          end

          context "failure" do
            let!(:stubs) { [stub(query, bodies[0], 400)] }
            it_behaves_like "pagination"
          end
        end

        context "when a query matches many results" do
          let(:bodies) {
            [
              { count: 3, next: "next", previous: nil,    results: [{ a: "a1" }] }.to_json,
              { count: 3, next: "next", previous: "prev", results: [{ b: "b2" }] }.to_json,
              { count: 3, next: nil,    previous: "prev", results: [{ c: "c3" }] }.to_json
            ]
          }

          def create_stubs(status)
            [
              stub(query,                              bodies[0], status[0]),
              stub(query.merge(page: 2, page_size: 1), bodies[1], status[1]),
              stub(query.merge(page: 3, page_size: 1), bodies[2], status[2])
            ]
          end

          context "with successful pages" do
            let(:page_size) { 1 }
            let!(:stubs) { create_stubs([200, 200, 200]) }
            it_behaves_like "pagination"
          end

          context "with successful pages followed by a failed page" do
            let(:page_size) { 1 }
            let!(:stubs) { create_stubs([200, 200, 400]) }
            it_behaves_like "pagination"
          end

          context "with a response that changes the page size" do
            # page_size == 25 (a default), then it changes to 1
            let!(:stubs) { create_stubs([200, 200, 400]) }
            it_behaves_like "pagination"
          end
        end
      end
    end
  end
end
