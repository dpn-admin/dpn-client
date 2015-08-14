# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "dpn/client/agent/configuration"
require "dpn/client/agent/connection"

module DPN
  module Client
    class Agent
      include DPN::Client::Agent::Configuration
      include DPN::Client::Agent::Connection


    end
  end
end