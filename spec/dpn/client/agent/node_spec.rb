# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Node do
  before(:all) { WebMock.enable! }
  let(:agent) { DPN::Client::Agent.new(api_root: test_api_root, auth_token: "some_auth_token") }
  let(:body) { {foo: "bar"} }

  describe "#nodes" do
    it "queries /node/?page=1&page_size=25" do
      stub = stub_request(:get, dpn_url("/node/?page=1&page_size=25"))
        .to_return(body: body.to_json, status: 200, headers: {content_type: "application/json"})

      agent.nodes {}
      expect(stub).to have_been_requested
    end
  end



end