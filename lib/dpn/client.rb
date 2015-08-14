# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "dpn/client/agent"

module DPN
  module Client

    # Get the api version, based on the major version of this library.
    def self.api_version
      DPN::Client::VERSION.split(".")[0]
    end


    def client(*options)
      return ::DPN::Client::Agent.new options
    end
    alias agent client


  end
end