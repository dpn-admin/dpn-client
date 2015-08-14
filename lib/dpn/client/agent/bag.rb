# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    module Agent
      module Bag

        # Get the bags index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of entries per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] :admin_node (nil) Namespace of the admin_node of the bag.
        # @option options [String] :bag_type (nil) One of D, R, I, for data, rights, and
        #   interpretive, respectively.
        # @yield [Array<Hash>] Optional block to process each page of
        #   nodes.
        # @return [Array<Hash>]
        def bags(options = {page_size: 25}, &block)
          paginate "/bag/", options, &block
        end
        alias index bags


        # @overload bag(uuid, &block)
        #   Get a specific bag
        #   @param [String] uuid UUID of the bag.
        #   @yield [Response]
        #   @return [Response]
        # @overload bag(options)
        #   Alias for #bags
        #   @return [Array<Hash>]
        #   @see #bags
        def bag(uuid = nil, options = {page_size: 25}, &block)
          if uuid
            get "/bag/#{uuid}/", nil, &block
          else
            bags(options, &block)
          end
        end


        # Create a bag
        # @param [Hash] bag Body of the bag
        # @yield [Response]
        # @return [Response]
        def create_bag(bag, &block)
          post "/bag/#{bag[:uuid]}/", bag, &block
        end


        # Update a bag
        # @param [Hash] bag Body of the bag
        # @yield [Response]
        # @return [Response]
        def update_bag(bag, &block)
          put "/bag/#{bag[:uuid]}/", bag, &block
        end


        # Delete a bag
        # @param [String] uuid UUID of the bag
        # @yield [Response]
        # @return [Response]
        def delete_bag(uuid, &block)
          delete "/bag/#{uuid}/", &block
        end

      end
    end
  end
end