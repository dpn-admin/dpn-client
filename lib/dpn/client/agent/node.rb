# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the node resource.
      module Node

        # Get the nodes index
        # @param [Hash] options
        # @option options [Fixnum] :page_size (25) Number of nodes per page
        # @yield [Hash] Optional block to process each node.
        # @return [Array<Hash>]
        def nodes(options = {page_size: 25})
          nodes = []
          paginate "/node/", options, options[:page_size] || 25 do |response|
            if response.success?
              response[:results].each do |node|
                nodes << node
                yield node
              end
            end
          end
          return nodes
        end


        # @overload node(namespace, &block)
        #   Get a specific node
        #   @param [String] namespace Namespace of the node.
        #   @yield [Response] Optional block to process the response.
        #   @return [Response]
        # @overload node(options, &block)
        #   Alias for #nodes
        #   @return [Array<Hash>]
        #   @see #nodes
        def node(namespace = nil, options = {page_size: 25}, &block)
          if namespace
            get "/node/#{namespace}/", nil, &block
          else
            nodes(options, &block)
          end
        end


        # Create a node
        # @param [Hash] node Body of the node
        # @yield [Response]
        # @return [Response]
        def create_node(node, &block)
          post "/node/", node, &block
        end


        # Update a node
        # @param [Hash] node Body of the node
        # @yield [Response]
        # @return [Response]
        def update_node(node, &block)
          put "/node/#{node[:namespace]}/", node, &block
        end


        # Delete a node
        # @param [String] namespace Namespace of the node.
        # @yield [Response]
        # @return [Response]
        def delete_node(namespace, &block)
          delete "/node/#{namespace}/", &block
        end

      end
    end
  end
end