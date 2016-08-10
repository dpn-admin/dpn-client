# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "dpn/client/agent/configuration"
require "dpn/client/agent/connection"
require "dpn/client/agent/bag"
require "dpn/client/agent/digest"
require "dpn/client/agent/fixity_check"
require "dpn/client/agent/ingest"
require "dpn/client/agent/member"
require "dpn/client/agent/node"
require "dpn/client/agent/replicate"
require "dpn/client/agent/restore"

module DPN
  module Client
    class Agent
      include DPN::Client::Agent::Configuration
      include DPN::Client::Agent::Connection

      include DPN::Client::Agent::Bag
      include DPN::Client::Agent::Digest
      include DPN::Client::Agent::FixityCheck
      include DPN::Client::Agent::Ingest
      include DPN::Client::Agent::Member
      include DPN::Client::Agent::Node
      include DPN::Client::Agent::Replicate
      include DPN::Client::Agent::Restore

      def initialize(options = {})
        self.configure(options)
      end

    end
  end
end