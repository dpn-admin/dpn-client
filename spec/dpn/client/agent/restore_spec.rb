# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Restore do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}
  restore_id = "somerestoreid"


  describe "#restores" do
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
            stub_request(:get, dpn_url("/restore/")).with(query: query.merge(page: 1))
              .to_return(body: bodies[0].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/restore/")).with(query: query.merge(page: 2))
              .to_return(body: bodies[1].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/restore/")).with(query: query.merge(page: 3))
              .to_return(body: bodies[2].to_json, status: 200, headers: headers)
          ]
        }

        it_behaves_like "a paged endpoint", :restores, query.merge(page: 1)
      end
    end
  end


  describe "#restore" do
    let!(:stub) {
      stub_request(:get, dpn_url("/restore/#{restore_id}/"))
        .to_return(body: {a: :b}.to_json, status: 200, headers: headers)
    }
    it_behaves_like "a single endpoint", :restore, restore_id
  end


  describe "create_restore" do
    body = { restore_id: restore_id, foo: "bar" }
    let!(:stub) {
      stub_request(:post, dpn_url("/restore/"))
        .to_return(body: body.to_json, status: 201, headers: headers)
    }

    it_behaves_like "a single endpoint", :create_restore, body
  end


  describe "update_restore" do
    body = { restore_id: restore_id, foo: "bar" }
    let!(:stub) {
      stub_request(:put, dpn_url("/restore/#{restore_id}/"))
        .to_return(body: body.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :update_restore, body
  end



end
