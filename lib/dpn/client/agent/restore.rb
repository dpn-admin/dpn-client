# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent
      module Restore

        # Get the restore request index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of entries per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] bag (nil) Filter by a specific bag's UUID.
        # @option options [String] :to_node (nil) Namespace of the to_node of the bag.
        # @option options [String] :from_node (nil) Namespace of the from_node of the bag.
        # @option options [Boolean] accepted (nil) Filter by the value of accepted.
        # @option options [Boolean] finished (nil) Filter by the value of finished.
        # @option options [Boolean] cancelled (nil) Filter by the value of cancelled.
        # @option options [String] cancel_reason (nil) Filter by cancel_reason.
        # @yield [Response] Optional block to process each individual result.
        # @return [Array<Hash>] Array of all restore data. Generated and returned
        #   only if no block is passed.
        def restores(options = {page_size: 25}, &block)
          paginate_each "/restore/", options, options[:page_size], &block
        end


        # Get a specific restore request.
        # @param [String] restore_id
        # @yield [Response]
        # @return [Response]
        def restore(restore_id, &block)
          get "/restore/#{restore_id}/", nil, &block
        end


        # Create a restore request
        # @param [Hash] request Body of the restore request
        # @yield [Response]
        # @return [Response]
        def create_restore(request, &block)
          post "/restore/", request, &block
        end


        # Update a restore request
        # @param [Hash] request Body of the restore request
        # @yield [Response]
        # @return [Response]
        def update_restore(request, &block)
          put "/restore/#{request[:restore_id]}/", request, &block
        end

      end
    end
  end
end