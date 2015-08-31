# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

describe DPN::Client::Agent::Configuration do
  describe "#configure" do
    it "returns the configured agent" do
      agent = DPN::Client.client.configure do |c|
        c.api_root = "https://hathitrust.org/api_root"
        c.auth_token = "auth_token_for_hathi"
      end
      expect(agent).to be_a DPN::Client::Agent
      expect(agent.api_root).to eql("https://hathitrust.org/api_root")
      expect(agent.auth_token).to eql("auth_token_for_hathi")
    end
  end
end
