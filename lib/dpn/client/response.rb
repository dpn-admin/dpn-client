# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "httpclient"
require "json"

module DPN
  module Client
    class Response


      def initialize(httpclient_message_response)
        @cached_json = httpclient_message_response.body
        @body = JSON.parse(@cached_json, symbolize_names: true)
        @status = httpclient_message_response.header.status_code
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

      # Removing the assignment operations pending a use case v2.0.0

      # def []=(key, value)
      #   @cached_json = nil
      #   @body[key.to_sym] = value
      # end


      # def body=(value)
      #   raise ArgumentError unless value.class == Hash
      #   @cached_json = nil
      #   @body = value
      # end


    end
  end
end