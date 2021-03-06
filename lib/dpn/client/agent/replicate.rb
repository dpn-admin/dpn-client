# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent
      module Replicate

        # Get the replication request index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of entries per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] bag (nil) Filter by a specific bag's UUID.
        # @option options [String] :to_node (nil) Namespace of the to_node of the bag.
        # @option options [String] :from_node (nil) Namespace of the from_node of the bag.
        # @option options [Boolean] store_requested (nil) Filter by the value of store_requested.
        # @option options [Boolean] stored (nil) Filter by the value of stored.
        # @option options [Boolean] cancelled (nil) Filter by the value of cancelled.
        # @option options [String] cancel_reason (nil) Filter by cancel_reason.
        # @yield [Response] Block to process each individual replication.
        def replications(options = {page_size: 25}, &block)
          paginate_each "/replicate/", options, options[:page_size], &block
        end


        # @overload replicate(replication_id, &block)
        #   Get a specific replication request.
        #   @param [String] replication_id
        #   @yield [Response]
        #   @return [Response]
        # @overload replicate(options, &block)
        #   Alias for #replications
        #   @return [Array<Hash>]
        #   @see #replications
        def replicate(replication_id, &block)
          get "/replicate/#{replication_id}/", nil, &block
        end


        # Alias of #replicate
        def replication(replication_id, &block)
          replicate replication_id, &block
        end


        # Create a replication request
        # @param [Hash] request Body of the replication request
        # @yield [Response]
        # @return [Response]
        def create_replication(request, &block)
          post "/replicate/", request, &block
        end


        # Update a replication request
        # @param [Hash] request Body of the replication request
        # @yield [Response]
        # @return [Response]
        def update_replication(request, &block)
          put "/replicate/#{request[:replication_id]}/", request, &block
        end

      end
    end
  end
end