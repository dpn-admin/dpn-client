# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Replicate do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}
  repl_id = "somereplid"

  shared_examples "replications" do
    page_size = 1
    query_set_1 = {}
    query_set_2 = {
      after: "2015-08-26T19:20:54Z",
      uuid: "some_uuid",
      store_requested: true,
      stored: true,
      cancelled: false,
      from_node: "some_from_node",
      to_node: "some_to_node",
      order_by: "created_at"
    }
    query_set_3 = {
      cancel_reason: 'reject'
    }

    [query_set_1, query_set_2, query_set_3].each do |query_set|
      context "with query_set of size #{query_set.size}" do
        query = query_set.merge({ page_size: 1})
        let!(:bodies) {[
          {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]},
          {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]},
          {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}
        ]}
        let!(:stubs) {
          [
            stub_request(:get, dpn_url("/replicate/")).with(query: query.merge(page: 1))
              .to_return(body: bodies[0].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/replicate/")).with(query: query.merge(page: 2))
              .to_return(body: bodies[1].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/replicate/")).with(query: query.merge(page: 3))
              .to_return(body: bodies[2].to_json, status: 200, headers: headers)
          ]
        }

        it_behaves_like "a paged endpoint", :replications, query.merge(page: 1)
      end # with query_set of size...
    end # loop on query sets
  end # shared examples replications



  describe "#replications" do
    it_behaves_like "replications"
  end


  describe "#replicate" do
    context "without a replication id" do
      it_behaves_like "replications"
    end
    context "with a replication id" do
      let!(:stub) {
        stub_request(:get, dpn_url("/replicate/#{repl_id}/"))
          .to_return(body: {a: :b}.to_json, status: 200, headers: headers)
      }
      it_behaves_like "a single endpoint", :replicate, repl_id
    end
  end


  describe "create_replication" do
    body = { replication_id: repl_id, foo: "bar" }
    let!(:stub) {
      stub_request(:post, dpn_url("/replicate/"))
        .to_return(body: body.to_json, status: 201, headers: headers)
    }

    it_behaves_like "a single endpoint", :create_replication, body
  end


  describe "update_replication" do
    body = { replication_id: repl_id, foo: "bar" }
    let!(:stub) {
      stub_request(:put, dpn_url("/replicate/#{repl_id}/"))
        .to_return(body: body.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :update_replication, body
  end


  describe "delete_replication" do
    let!(:stub) {
      stub_request(:delete, dpn_url("/replicate/#{repl_id}/"))
        .to_return(body: {}.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :delete_replication, repl_id
  end



end