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
        # @option options [DateTime,String] :after (nil) Include only entries last modified
        #   after this date.  Takes a properly formatted string, or a datetime.
        # @option options [String] uuid (nil) Filter by a specific bag's UUID.
        # @option options [String] status (nil) Filter by status.
        # @option options [Boolean] fixity_accept (nil) Filter by the value of fixity_accept.
        # @option options [Boolean] bag_valid (nil) Filter by the value of bag_valid.
        # @option options [String] :from_node (nil) Namespace of the from_node of the bag.
        # @option options [String] :to_node (nil) Namespace of the to_node of the bag.
        # @option options [String] :order_by (nil) Comma-separated list of strings to order the
        #   result by.  Accepted values are 'created_at' and 'updated_at'
        # @yield [Response] Optional block to process each individual replication.
        # @return [Array<Hash>] Array of all replication data. Generated and returned
        #   only if no block is passed.
        def replications(options = {page_size: 25}, &block)
          if options[:after].is_a?(DateTime)
            options[:after] = options[:after].new_offset(0).strftime(DPN::Client.time_format)
          end

          return paginate_each "/replicate/", options, options[:page_size], &block
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
        def replicate(replication_id = nil, options = {page_size: 25}, &block)
          if replication_id
            get "/replicate/#{replication_id}/", nil, &block
          else
            replications(options, &block)
          end
        end


        # Create a replication request
        # @param [Hash] request Body of the replication request
        # @yield [Response]
        # @return [Response]
        def create_replication(request, &block)
          post "/replicate", request, &block
        end


        # Update a replication request
        # @param [Hash] request Body of the replication request
        # @yield [Response]
        # @return [Response]
        def update_replication(request, &block)
          put "/replicate/#{request[:replication_id]}/", request, &block
        end


        # Delete a replication request
        # @param [String] replication_id The replication_id of the replication request
        # @yield [Response]
        # @return [Response]
        def delete_replication(replication_id, &block)
          delete "/replicate/#{replication_id}/", &block
        end

      end
    end
  end
end