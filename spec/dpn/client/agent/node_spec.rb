# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Node do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  headers =  {content_type: "application/json"}
  node_name = "hathi"


  describe "#node" do
    let!(:stub) {
      stub_request(:get, dpn_url("/node/#{node_name}/"))
        .to_return(body: {a: :b}.to_json, status: 200, headers: headers)
    }
    it_behaves_like "a single endpoint", :node, node_name
  end


  describe "update_node" do
    body = { namespace: node_name, foo: "bar" }
    let!(:stub) {
      stub_request(:put, dpn_url("/node/#{node_name}/"))
        .to_return(body: body.to_json, status: 200, headers: headers)
    }

    it_behaves_like "a single endpoint", :update_node, body
  end



end