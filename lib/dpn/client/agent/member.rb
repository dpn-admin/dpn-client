# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the member resource.
      module Member

        # Get the members index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of members per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @yield [Response] Block to process each individual member.
        def members(options = {page_size: 25}, &block)
          paginate_each "/member/", options, options[:page_size], &block
        end


        # Get a specific member
        # @param [String] uuid UUIDv4 of the member.
        # @yield [Response] Optional block to process the response.
        # @return [Response]
        def member(uuid = nil, &block)
          get "/member/#{uuid}/", nil, &block
        end


        # Get a member's bags
        # @param [String] uuid The specific member's uuid
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of entries per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] :admin_node (nil) Namespace of the admin_node of the bag.
        # @option options [String] :bag_type (nil) One of 'D', 'R', 'I', for data, rights, and
        #   interpretive, respectively.
        # @yield [Response] Optional block to process individual bag.
        # @return [Array<Hash>] Array of all bag data. Generated and returned
        #   only if no block is passed.
        def member_bags(uuid, options = {page_size: 25}, &block)
          paginate_each "/member/#{uuid}/bags/", options, options[:page_size], &block
        end


        # Create a member
        # @param [Hash] member Body of the member
        # @yield [Response]
        # @return [Response]
        def create_member(member, &block)
          post "/member/", member, &block
        end


        # Update a member
        # @param [Hash] member Body of the member
        # @yield [Response]
        # @return [Response]
        def update_member(member, &block)
          put "/member/#{member[:uuid]}/", member, &block
        end


        # Delete a member
        # @param [String] uuid UUIDv4 of the member.
        # @yield [Response]
        # @return [Response]
        def delete_member(uuid, &block)
          delete "/member/#{uuid}/", &block
        end


      end

    end
  end
end