# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent
      module Configuration
        @@keys = [
            :api_root, :auth_token,
            :per_page, :user_agent
        ]

        @@defaults = {
            api_root: nil.freeze,
            auth_token: nil.freeze,
            per_page: 25.freeze,
            user_agent: "dpn-client".freeze
        }.freeze

        attr_accessor :api_root, :auth_token,
                      :per_page, :user_agent


        # Apply the options hash to the configuration
        def configure(options_hash)
          Configuration.keys.each do |key|
            instance_variable_set(:"@#{key}", options_hash[key])
          end
          if block_given?
            yield self
          end
        end


        # Reset to default values
        def reset
          Configuration.keys.each do |key|
            instance_variable_set(:"@#{key}", Configuration.defaults[key])
            self
          end
        end
        alias setup reset

        def base_url
          File.join(@api_root, "api-v#{DPN::Client.api_version}")
        end

        protected

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