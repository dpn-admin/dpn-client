# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Bag do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}
  uuid = "some_uuid"

  shared_examples "bags" do
    page_size = 1
    query_set_1 = {}
    query_set_2 = {
      before: "2015-08-31T19:20:54Z",
      after: "2015-08-1T19:20:54Z",
      admin_node: "some_admin_node",
      status: "some_status",
      bag_type: %w(D R I d r i).sample
    }
    query_set_3 = {
      status: :complete
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
            stub_request(:get, dpn_url("/bag/")).with(query: query.merge(page: 1))
              .to_return(body: bodies[0].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/bag/")).with(query: query.merge(page: 2))
              .to_return(body: bodies[1].to_json, status: 200, headers: headers),
            stub_request(:get, dpn_url("/bag/")).with(query: query.merge(page: 3))
              .to_return(body: bodies[2].to_json, status: 200, headers: headers)
          ]
        }

        it_behaves_like "a paged endpoint", :bags, query.merge(page: 1)
      end # with query_set of size...
    end # loop on query sets
  end # shared examples bags



  describe "#bags" do
    it_behaves_like "bags"
  end


  describe "#bag" do
    context "without a uuid" do
      it_behaves_like "bags"
    end
    context "with a uuid" do
      let!(:stub) {
        stub_request(:get, dpn_url("/bag/#{uuid}/"))
          .to_return(body: {a: :b}.to_json, status: 200, headers: headers)
      }
      it_behaves_like "a single endpoint", :bag, uuid
    end
  end


  describe "create_bag" do
    body = { uuid: uuid, foo: "bar" }
    let!(:stub) {
      stub_request(:post, dpn_url("/bag/"))
        .to_return(body: body.to_json, status: 201, headers: headers)
    }

    it_behaves_like "a single endpoint", :create_bag, body
  end


  describe "update_bag" do
    body = { uuid: uuid, foo: "bar" }
    let!(:stub) {
      stub_request(:put, dpn_url("/bag/#{uuid}/"))
        .to_return(body: body.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :update_bag, body
  end


  describe "delete_bag" do
    let!(:stub) {
      stub_request(:delete, dpn_url("/bag/#{uuid}/"))
        .to_return(body: {}.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :delete_bag, uuid
  end



end