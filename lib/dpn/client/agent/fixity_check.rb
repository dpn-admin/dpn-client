# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the fixity_check resource.
      module FixityCheck

        # Get the fixity_check index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of results per page
        # @option options [DateTime String] :before (nil) Include only entries last modified
        #   before this date.
        # @option options [DateTime String] :after (nil) Include only entries last modified
        #   after this date.
        # @option options [String] bag (nil) Filter by a specific bag's UUID.
        # @option options [Boolean] latest (false) Request latest results only.
        # @option options [String] :node (nil) Namespace of the node.
        # @yield [Response] Block to process each individual result.
        def fixity_checks(options = {page_size: 25}, &block)
          paginate_each "/fixity_check/", options, options[:page_size], &block
        end


        # Create a fixity_check
        # @param [Hash] fixity_check Body of the fixity_check
        # @yield [Response]
        # @return [Response]
        def create_fixity_check(fixity_check, &block)
          post "/fixity_check/", fixity_check, &block
        end

      end

    end
  end
end