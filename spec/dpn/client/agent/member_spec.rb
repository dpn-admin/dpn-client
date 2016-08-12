# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Member do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}
  member_id = SecureRandom.uuid

  shared_examples "members" do
    page_size = 1
    let!(:query) { {} }
    let!(:bodies) {[
      {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]},
      {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]},
      {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}
    ]}
    let!(:stubs) {
      [
        stub_request(:get, dpn_url("/member/?page=1&page_size=#{page_size}"))
          .to_return(body: bodies[0].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/member/?page=2&page_size=#{page_size}"))
          .to_return(body: bodies[1].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/member/?page=3&page_size=#{page_size}"))
          .to_return(body: bodies[2].to_json, status: 200, headers: headers)
      ]
    }

    it_behaves_like "a paged endpoint", :members, {page_size: page_size}
  end

  describe "#members" do
    it_behaves_like "members"
  end


  describe "#member" do
    let!(:stub) {
      stub_request(:get, dpn_url("/member/#{member_id}/"))
        .to_return(body: {a: :b}.to_json, status: 200, headers: headers)
    }
    it_behaves_like "a single endpoint", :member, member_id
  end


  describe "#member_bags" do
    page_size = 1
    let!(:query) { {} }
    let!(:bodies) {[
      {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]},
      {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]},
      {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}
    ]}
    let!(:stubs) {
      [
        stub_request(:get, dpn_url("/member/#{member_id}/bags/?page=1&page_size=#{page_size}"))
          .to_return(body: bodies[0].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/member/#{member_id}/bags/?page=2&page_size=#{page_size}"))
          .to_return(body: bodies[1].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/member/#{member_id}/bags/?page=3&page_size=#{page_size}"))
          .to_return(body: bodies[2].to_json, status: 200, headers: headers)
      ]
    }
    it_behaves_like "a paged endpoint", :member_bags, member_id, {page_size: page_size}
  end


  describe "create_member" do
    body = { member_id: member_id, foo: "bar" }
    let!(:stub) {
      stub_request(:post, dpn_url("/member/"))
        .to_return(body: body.to_json, status: 201, headers: headers)
    }

    it_behaves_like "a single endpoint", :create_member, body
  end


  describe "update_member" do
    body = { member_id: member_id, foo: "bar" }
    let!(:stub) {
      stub_request(:put, dpn_url("/member/#{member_id}/"))
        .to_return(body: body.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :update_member, body
  end


  describe "delete_member" do
    let!(:stub) {
      stub_request(:delete, dpn_url("/member/#{member_id}/"))
        .to_return(body: {}.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :delete_member, member_id
  end



end