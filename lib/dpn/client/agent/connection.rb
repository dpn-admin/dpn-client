# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "uri"
require "json"
require "httpclient"
require "csv" # stringify_nested_arrays!
require "dpn/client/response"

module DPN
  module Client
    class Agent
      module Connection

        # Make a GET request
        # @param url [String] The path, relative to base_url
        # @param query [Hash] Optional query parameters.
        # @yield [Response] Optional block that takes the
        #   response object as a parameter.
        # @return [Response]
        def get(url, query = nil, &block)
          request :get, url, query, nil, &block
        end


        # Make a POST request
        # @param url [String] The path, relative to base_url
        # @param body [String] The message body.
        # @yield [Response] Optional block that takes the
        #   response object as a parameter.
        # @return [Response]
        def post(url, body, &block )
          request :post, url, nil, body, &block
        end


        # Make a PUT request
        # @param url [String] The path, relative to base_url
        # @param body [String] The message body.
        # @yield [Response] Optional block that takes the
        #   response object as a parameter.
        # @return [Response]
        def put(url, body, &block)
          request :put, url, nil, body, &block
        end


        # Make a DELETE request
        # @param url [String] The path, relative to base_url
        # @yield [Response] Optional block that takes the
        #   response object as a parameter.
        # @return [Response]
        def delete(url, &block)
          request :delete, url, nil, nil, &block
        end


        # Make a one or more GET requests, fetching the next
        # page of results one page at a time, so long as the
        # response indicates there is another page.
        # @param url [String] The path, relative to base_url
        # @param query [Hash] Optional query parameters.
        # @param page_size [Fixnum] The number of results to request
        #   from each page.
        # @yield [Response] Mandatory block that takes a page
        #   of results (the response object) as a parameter.
        #   The results will be available via response[:results].
        def paginate(url, query, page_size, &block)
          raise ArgumentError, "Must pass a block" unless block_given?

          query ||= {}
          query = query.merge({ :page_size => page_size, :page => 1})

          response = get(url, query) # pass an empty block so we can call the block manually on :results
          yield response
          while response.success? && response[:next] && response[:results].empty? == false
            query[:page] += 1
            query[:page_size] = response[:results].size # in case the server specifies a different page size
            response = get(url, query) {}
            yield response
          end
        end


        # Make a one or more GET requests, fetching the next
        # page of results one page at a time, so long as the
        # response indicates there is another page.  This method
        # yields each individual result, wrapped in a [Response].
        # @param url [String] The path, relative to base_url
        # @param query [Hash] Optional query parameters.
        # @param page_size [Fixnum] The number of results to request
        #   from each page.
        # @yield [Response] Mandatory block that takes each individual
        #   result wrapped in a response object as a parameter.
        # @return [Array<Response>] The results iff a block is not passed.
        def paginate_each(url, query, page_size, &block)
          results = []
          paginate(url, query, (page_size || 25)) do |response|
            if response.success?
              response[:results].each do |result|
                if block_given?
                  individual_response = Response.from_data(response.status, result)
                  yield individual_response
                else
                  results << result
                end
              end
            end
          end

          unless block_given?
            return results
          end
        end


        protected

        def request(method, url, query, body, &block)
          url, extra_query = parse_url(url)
          query ||= {}
          options = {
              query: stringify_nested_arrays!(query.merge(extra_query)),
              body: body.to_json,
              follow_redirect: true
          }

          logger.info("Sending #{method.upcase}: #{fix_url(url)} #{options} ")
          raw_response = connection.request method, fix_url(url), options
          response = DPN::Client::Response.new(raw_response)
          logger.info("Received #{response.status}")
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