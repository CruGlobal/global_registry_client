require "faraday"
require "oj"
require "retryable"
require "addressable/uri"

module GlobalRegistry
  class Base
    def initialize(args = {})
      @base_url = args[:base_url]
      @access_token = args[:access_token]
      @xff = args[:xff]
    end

    def self.find(id, params = {}, headers = {})
      new.find(id, params, headers)
    end

    def find(id, params = {}, headers = {})
      request(:get, params, path_with_id(id), headers)
    end

    def self.get(params = {}, headers = {})
      new.get(params, headers)
    end

    def get(params = {}, headers = {})
      request(:get, params, nil, headers)
    end

    def get_all_pages(params = {}, headers = {})
      results = results_from_all_pages(params, headers)
      return results unless block_given?
      results.each { |result| yield result }
    end

    def self.post(params = {}, headers = {})
      new.post(params, headers)
    end

    def post(params = {}, headers = {})
      request(:post, params, nil, headers)
    end

    def self.put(id, params = {}, headers = {})
      new.put(id, params, headers)
    end

    def put(id, params = {}, headers = {})
      request(:put, params, path_with_id(id), headers)
    end

    def self.delete(id, headers = {})
      new.delete(id, headers)
    end

    def delete(id, headers = {})
      request(:delete, {}, path_with_id(id), headers)
    end

    def self.delete_or_ignore(id, headers = {})
      delete(id, headers)
    rescue Faraday::ResourceNotFound
      # Ignore 404 errors
    end

    def delete_or_ignore(id, headers = {})
      delete(id, headers)
    rescue Faraday::ResourceNotFound
      # Ignore 404 errors
    end

    def self.request(method, params, path = nil, headers = {})
      new.request(method, params, path, headers)
    end

    def request(method, params, path = nil, headers = {})
      raise "You need to configure GlobalRegistry with your access_token." unless access_token

      url = if base_url.start_with? "http"
        Addressable::URI.parse(base_url)
      else
        Addressable::URI.parse("http://#{base_url}")
      end
      url.path = path || default_path
      url.query_values = headers.delete(:params) if headers[:params]

      # Create Faraday connection
      connection = Faraday.new(url: "#{url.scheme}://#{url.host}") do |faraday|
        faraday.adapter Faraday.default_adapter
      end

      # Set default headers
      request_headers = default_headers.merge(headers)

      begin
        case method
        when :post
          request_headers["Content-Type"] = "application/json"
          response = connection.post(url.path, params.to_json, request_headers)
        when :put
          request_headers["Content-Type"] = "application/json"
          response = connection.put(url.path, params.to_json, request_headers)
        when :get, :delete
          # Add query parameters for GET and DELETE requests
          query_params = params.any? ? params : nil
          response = if method == :get
            connection.get(url.path, query_params, request_headers)
          else # :delete
            connection.delete(url.path, query_params, request_headers)
          end
        end

        handle_response(response)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
        # Handle only network/transport errors, not HTTP status errors
        raise GlobalRegistry::OtherError.new(e.message)
      end
    end

    def default_path
      self.class.to_s.split("::").last.underscore.pluralize
    end

    def path_with_id(id)
      "#{default_path}/#{id}"
    end

    private

    def default_headers
      headers = {"Authorization" => "Bearer #{access_token}", "Accept" => "application/json"}
      headers = headers.merge("X-Forwarded-For" => @xff) if @xff.present?
      headers
    end

    def handle_response(response)
      case response.status
      when 200..299
        Oj.load(response.body)
      when 400
        raise GlobalRegistry::BadRequest.new(response.status.to_s)
      when 404
        raise GlobalRegistry::ResourceNotFound.new(response.status.to_s)
      when 500
        raise GlobalRegistry::InternalServerError.new(response.status.to_s)
      else
        puts response.inspect
        raise GlobalRegistry::OtherError, response.status.to_s
      end
    end

    def base_url
      @base_url || GlobalRegistry.base_url
    end

    def access_token
      @access_token || GlobalRegistry.access_token
    end

    def results_from_all_pages(params, headers)
      result = get(params, headers)
      overall_result = result
      loop do
        break unless result["meta"] && result["meta"]["next_page"]
        page = result["meta"]["page"].to_i + 1
        result = get(params.merge(page: page), headers)
        add_result(overall_result, result)
      end
      # Return the root result node
      overall_result.values.first
    end

    def add_result(overall_result, result)
      overall_result.each do |key, value|
        next unless value.is_a?(Array)
        overall_result[key] = value.concat(result[key])
      end
      overall_result.delete("meta")
    end
  end
end
