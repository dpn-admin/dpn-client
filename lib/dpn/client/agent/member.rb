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
        # @yield [Response] Optional block to process each individual member.
        # @return [Array<Hash>] Array of all member data. Generated and returned
        #   only if no block is passed.
        def members(options = {page_size: 25}, &block)
          return paginate_each "/member/", options, options[:page_size], &block
        end


        # @overload member(uuid, &block)
        #   Get a specific member
        #   @param [String] uuid UUIDv4 of the member.
        #   @yield [Response] Optional block to process the response.
        #   @return [Response]
        # @overload member(options, &block)
        #   Alias for #members
        #   @return [Array<Hash>]
        #   @see #members
        def member(uuid = nil, options = {page_size: 25}, &block)
          if uuid
            get "/member/#{fix_uuid(uuid)}/", nil, &block
          else
            members(options, &block)
          end
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
          put "/member/#{fix_uuid(member[:uuid])}/", member, &block
        end


        # Delete a member
        # @param [String] uuid UUIDv4 of the member.
        # @yield [Response]
        # @return [Response]
        def delete_member(uuid, &block)
          delete "/member/#{fix_uuid(uuid)}/", &block
        end


        private
        # Add dashes to a uuid if they are missing
        def fix_uuid(uuid)
          if uuid && uuid.size == 32
            unless uuid.include?("-")
              uuid.insert(8, "-")   # 9th, 14th, 19th and 24th
              uuid.insert(13, "-")
              uuid.insert(18, "-")
              uuid.insert(23, "-")
            end
          end
          uuid.downcase
        end
        

      end

    end
  end
end