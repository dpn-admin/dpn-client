# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "logger"

module DPN
  module Client
    class Agent
      module Configuration
        @@keys = [
            :api_root, :auth_token,
            :per_page, :user_agent,
            :logger
        ]

        @@defaults = {
            api_root: nil.freeze,
            auth_token: nil.freeze,
            per_page: 25.freeze,
            user_agent: "dpn-client".freeze
        }.freeze

        attr_accessor :api_root, :auth_token,
                      :per_page, :user_agent
        attr_writer :logger

        def api_ver
          @api_ver ||= "api-v#{DPN::Client.api_version}"
        end

        def base_url
          @api_root
        end

        # Apply the options hash to the configuration
        def configure(options_hash = {})
          keys.each do |key|
            if options_hash[key]
              instance_variable_set(:"@#{key}", options_hash[key])
            end
          end
          if block_given?
            yield self
          end
          return self
        end


        # Reset to default values
        def reset
          keys.each do |key|
            instance_variable_set(:"@#{key}", defaults[key])
            self
          end
        end
        alias_method  :setup, :reset


        def logger
          @logger ||= NullLogger.new
        end

        protected

        class NullLogger < Logger
          def initialize(*args); end
          def add(*args, &block); end
        end

        def defaults
          @@defaults
        end

        def keys
          @@keys
        end


      end
    end
  end
end
