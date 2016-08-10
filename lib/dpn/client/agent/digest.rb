# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the digest resource.
      module Digest

        # Get the digests index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of results per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @yield [Response] Block to process each individual result.
        def digests(options = {page_size: 25}, &block)
          paginate_each "/digest/", options, options[:page_size], &block
        end


        # Get the digests for a specific bag
        # @option options [Fixnum] :page_size (25) Number of results per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @yield [Response] Block to process each individual result.
        def bag_digests(bag, options = {page_size: 25}, &block)
          paginate_each "/bag/#{bag}/digest/", options, options[:page_size], &block
        end


        # Get a specific digest
        # @param [String] bag UUIDv4 of the bag.
        # @param [String] algorithm Name of the algorithm.
        # @yield [Response] Optional block to process the response.
        # @return [Response]
        def digest(bag, algorithm, &block)
          get "/bag/#{bag}/digest/#{algorithm}/", nil, &block
        end


        # Create a digest
        # @param [Hash] digest Body of the digest
        # @yield [Response]
        # @return [Response]
        def create_digest(digest, &block)
          post "/bag/#{digest[:bag]}/digest/", digest, &block
        end

      end

    end
  end
end