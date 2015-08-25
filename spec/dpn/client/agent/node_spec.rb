# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Node do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }



  describe "#nodes" do
    let!(:query) { {} }
    let!(:page_size) { 1 }
    let!(:bodies) {[
      {count: 3, next: "next", previous: nil, results: [{ a: "a1" }]},
      {count: 3, next: "next", previous: "prev", results: [{ b: "b2" }]},
      {count: 3, next: nil, previous: "prev", results: [{ c: "c3" }]}
    ]}
    let!(:headers) { {content_type: "application/json"} }
    let!(:stubs) {
      [
        stub_request(:get, dpn_url("/node/?page=1&page_size=#{page_size}"))
          .to_return(body: bodies[0].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/node/?page=2&page_size=#{page_size}"))
          .to_return(body: bodies[1].to_json, status: 200, headers: headers),
        stub_request(:get, dpn_url("/node/?page=3&page_size=#{page_size}"))
          .to_return(body: bodies[2].to_json, status: 200, headers: headers)
      ]
    }

    it "requests the correct endpoints" do
      agent.nodes(page_size: page_size) {}
      stubs.each do |stub|
        expect(stub).to have_been_requested
      end
    end

    it "returns the aggregated nodes" do
      nodes = agent.nodes(page_size: page_size) {}
      results = bodies.collect { |body| body[:results]}
      expect(nodes).to eql(results.flatten)
    end

    it "executes the block on each node" do
      results = bodies.collect { |body| body[:results]}
      expect{ |probe|
        agent.nodes(page_size: page_size, &probe)
      }.to yield_successive_args( *(results.flatten) ) # asterisk explodes the array
    end
  end



end