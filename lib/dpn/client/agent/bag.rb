# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent
      module Bag

        # Get the bags index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of entries per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] :admin_node (nil) Namespace of the admin_node of the bag.
        # @option options [String] :member (nil) The UUID of the member that owns or is vested
        #   in this bag.
        # @option options [String] :bag_type (nil) One of 'D', 'R', 'I', for data, rights, and
        #   interpretive, respectively.
        # @yield [Response] Optional block to process individual bag.
        # @return [Array<Hash>] Array of all bag data. Generated and returned
        #   only if no block is passed.
        def bags(options = {page_size: 25}, &block)
          [:after, :before].each do |date_field|
            if options[date_field].is_a?(DateTime)
              options[date_field] = options[:date_field].new_offset(0).strftime(DPN::Client.time_format)
            end
          end

          return paginate_each "/bag/", options, options[:page_size], &block
        end


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
          post "/bag", bag, &block
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