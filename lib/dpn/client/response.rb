# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "httpclient"
require "json"

module DPN
  module Client
    class Response

      attr_reader :status, :body

      def initialize(httpclient_response = nil)
        if httpclient_response
          load_from_response!(httpclient_response)
        end
      end


      # Manually create a response.
      def self.from_data(status, body)
        self.new.load_from_data!(status, body)
      end

      attr_reader :status, :body


      def json
        @cached_json ||= @body.to_json
      end
      alias_method :to_json, :json
      alias_method :to_s, :json


      def ok?
        [ 200, 201, 202, 203, 204, 205, 206, 207, 208, 226].include?(@status)
      end
      alias_method :success?, :ok?


      def keys
        @body.keys
      end


      def [](key)
        @body[key.to_sym]
      end


      def load_from_data!(status, body)
        @body = body
        @status = status
        return self
      end

      def load_from_response!(httpclient_message_response)
        raw_body = httpclient_message_response.body
        @status = httpclient_message_response.header.status_code
        begin
          @body = JSON.parse(raw_body, symbolize_names: true)
          @cached_json = raw_body
        rescue JSON::ParserError
          @body = {
            status: @status,
            parsed: nil,
            raw: raw_body
          }
          @cached_json = @body.to_json
          if success? # It wasn't actually successful
            @status = 999
          end
        end
        return self
      end

      def ==(other)
        status == other.status && body == other.body
      end
      alias_method :eql?, :==

    end
  end
end