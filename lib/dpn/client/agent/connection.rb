# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "uri"
require "json"
require "httpclient"
require "csv" # stringify_nested_arrays!

module DPN
  module Client
    class Agent
      module Connection

        def get(url, query = nil, &block)
          request :get, url, query, nil, &block
        end

        def post(url, body, &block)
          request :post, url, nil, body, &block
        end

        def put(url, body, &block)
          request :put, url, nil, body, &block
        end

        def delete(url, &block)
          request :delete, url, nil, nil, &block
        end

        def paginate(url, query, page_size, &block)
          query ||= {}
          query = query.merge({ :page_size => page_size, :page => 1})
          if block_given?
            output = perform_paginate(url, query) { |results| block.call(results) }
          else
            output = perform_paginate(url, query) { |results| default_pagination_block.call(results) }
          end
          return output
        end


        protected

        def perform_paginate(url, query)
          response = get(url, query) # pass an empty block so we can call the block manually on :results
          yield response[:results] || []

          while response[:next] && response[:results].empty? == false
            query[:page] += 1
            response = get(url, query) {}
            yield response[:results] || []
          end
        end


        # Default pagination block, used to aggregate the results.
        def default_pagination_block
          @default_pagination_block ||= Proc.new { |response|
            all_results ||= []
            all_results << (response[:results] || [])
            all_results # return line
          }
        end


        def request(method, url, query, body, &block)
          url, extra_query = parse_url(url)
          query ||= {}
          options = {
              query: stringify_nested_arrays!(query.merge(extra_query)),
              body: body.to_json,
              follow_redirect: true
          }

          raw_response = connection.request method, fix_url(url), options
          response = DPN::Client::Response.new(raw_response)
          if block_given?
            yield response
          end

          return response
        end


        def parse_url(raw_url)
          url, query = raw_url.split("?", 2)
          url = File.join url, ""
          if query
            query = URI::decode_www_form(query).to_h
          else
            query = {}
          end
          return url, query
        end


        def connection
          @connection ||= ::HTTPClient.new({
              agent_name: user_agent,
              base_url: base_url,
              default_header: {
                  "Content-Type" => "application/json",
                  "Authorization" => "Token #{auth_token}"
              },
              force_basic_auth: true
          })
        end


        def fix_url(url)
          File.join url, "/"
        end


        # Convert array values to csv
        # Only goes one level deep.
        # @param [Hash] hash
        # @return [Hash]
        def stringify_nested_arrays!(hash)
          hash.keys.each do |key|
            if hash[key].kind_of?(Array)
              hash[key] = hash[key].to_csv.strip
            end
          end
          return hash
        end

      end
    end
  end
end