# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the ingest resource.
      module Ingest

        # Get the ingest index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of results per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] bag (nil) Filter by a specific bag's UUID.
        # @option options [Boolean] latest (false) Request latest results only.
        # @option options [Boolean] ingested (nil) Filter by value of the ingested field.
        # @option options [String] :node (nil) Namespace of the node.
        # @yield [Response] Block to process each individual result.
        def ingests(options = {page_size: 25}, &block)
          paginate_each "/ingest/", options, options[:page_size], &block
        end


        # Create a ingest
        # @param [Hash] ingest Body of the ingest
        # @yield [Response]
        # @return [Response]
        def create_ingest(ingest, &block)
          post "/ingest/", ingest, &block
        end

      end

    end
  end
end