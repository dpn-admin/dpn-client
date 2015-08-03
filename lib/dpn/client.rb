module DPN

  class Client

    # Get the api version, based on the major version of this library.
    def self.api_version
      DPN::Client::VERSION.split(".")[0]
    end


    def initialize(api_root, auth_cred)
      raise ArgumentError, "Missing api_root" unless api_root
      raise ArgumentError, "Missing auth_cred" unless auth_cred
      base_header = {
          "Content-Type" => "application/json",
          "Authorization" => "Token #{auth_cred}"
      }
      @client = HTTPClient.new( agent_name: DPN::Client.name,  # the module's name
                                base_url: File.join(api_root, DPN::Client.api_version),
                                default_header: base_header,
                                force_basic_auth: true)
    end


    # Issue a GET.
    # @param url [String]
    # @return [Response]
    def get(url)
      @client.get(fix_url(url), follow_redirect: true)
    end


    # Issue a POST.
    # @param url [String]
    # @param body [String]
    # @return [Response]
    def post(url, body)
      @client.post(fix_url(url), body, follow_redirect: true)
    end


    # Issue a PUT.
    # @param url [String]
    # @param body [String]
    # @return [Response]
    def put(url, body)
      # By default, HTTPClient doesn't let us tell it to
      # follow redirects for puts.  The following is a hack
      # to ensure that the follow_redirect option sticks around
      # past the @client.put call.
      args = {
          query: nil,
          body: body,
          header: nil,
          follow_redirect: true
      }
      @client.put(fix_url(url), args)
    end


    # Issue a DELETE.
    # @param url [String]
    # @return [Response]
    def delete(url)
      # Same issue as put.
      args = {
          query: nil,
          body: nil,
          header: nil,
          follow_redirect: true
      }
      @client.delete(fix_url(url), args)
    end


    # Given a list of records, find the most recent update time; examines
    # the :updated_at field.
    # @param records [Array<Hash>] The records
    # @param format [String] String of the format the dates are expected to be
    #   in.
    # @return [DateTime] A DateTime in the specified format.
    def self.last_update(records, format = Time::DATE_FORMATS[:dpn])
      newest = nil
      records.each do |record|
        record_time = DateTime.strptime(record[:updated_at], format)
        newest ||= record_time
        if record_time > newest
          newest = record_time
        end
      end
      return newest
    end


    # Construct an array that is not paged.  Uses a minimal set
    # of GET requests.  If a block is supplied, it will be passed
    # the results array of each page.
    # @param client [HTTPClient] The active HTTPClient client
    # @param url [String] The complete url to GET.
    # @param page_size [Fixnum] Size of pages to request.
    # @yield [results] A block to process the results on a page.
    # @yieldparam [Array<Hash>] records The records found on the page.
    def get_and_depaginate(url, page_size = 25, &block)
      if url.include?("?")
        unless url.include?("page_size=")
          url += "&page_size=#{page_size}"
        end
        unless url.include?("page=")
          url += "&page=1"
        end
      else
        url += "?page_size=#{page_size}&page=1"
      end

      self.get_and_depaginate_helper(url, &block)
    end


    private
    # Ensures that all addresses have a trailing slash.
    def fix_url(url)
      array_url = url.split("?", 2)
      array_url[0] = File.join(array_url[0], "/")
      return array_url.join("?")
    end


    # @param client [HTTPClient] The active HTTPClient client
    # @param page_url [String] The complete url to GET.
    # @yield [results] A block to process the results on a page.
    # @yieldparam [Array<Hash>] records The records found on the page.
    def get_and_depaginate_helper(page_url, &block)
      response = get(page_url)
      raise RuntimeError, "#{response.headers}\n#{response.body}" unless response.ok?
      page = JSON.parse(response.body, symbolize_names: true)
      yield page[:results] || []
      if page[:next] && page[:results].empty? == false
        next_page_url = page[:next]
        get_and_depaginate_helper(next_page_url, &block)
      end
    end
  end
end