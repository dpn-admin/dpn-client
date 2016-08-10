# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Ingest do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}

  describe "#ingests" do
    page_size = 1
    let!(:query) { {} }
    let!(:bodies) {[
      {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]},
      {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]},
      {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}
    ]}
    let!(:stubs) {
      [
        stub_request(:get, dpn_url("/ingest/?page=1&page_size=#{page_size}"))
          .to_return(body: bodies[0].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/ingest/?page=2&page_size=#{page_size}"))
          .to_return(body: bodies[1].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/ingest/?page=3&page_size=#{page_size}"))
          .to_return(body: bodies[2].to_json, status: 200, headers: headers)
      ]
    }

    it_behaves_like "a paged endpoint", :ingests, {page_size: page_size}
  end


  describe "#create_ingest" do
    body = { foo: "bar" }
    let!(:stub) {
      stub_request(:post, dpn_url("/ingest/"))
        .to_return(body: body.to_json, status: 201, headers: headers)
    }

    it_behaves_like "a single endpoint", :create_ingest, body
  end


end