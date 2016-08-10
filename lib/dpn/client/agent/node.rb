# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module DPN
  module Client
    class Agent

      # Operations on the node resource.
      module Node

        # Get a specific node
        # @param [String] namespace Namespace of the node.
        # @yield [Response] Optional block to process the response.
        # @return [Response]
        def node(namespace, &block)
          get "/node/#{namespace}/", nil, &block
        end


        # Update a node
        # @param [Hash] node Body of the node
        # @yield [Response]
        # @return [Response]
        def update_node(node, &block)
          put "/node/#{node[:namespace]}/", node, &block
        end


      end
    end
  end
end