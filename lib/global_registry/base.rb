require 'rest-client'
require 'oj'
require 'retryable'
require 'addressable/uri'

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
    rescue RestClient::Exception => e
      raise unless e.response.code.to_i == 404
    end
    def delete_or_ignore(id, headers = {})
      delete(id, headers)
    rescue RestClient::Exception => e
      raise unless e.response.code.to_i == 404
    end


    def self.request(method, params, path = nil, headers = {})
      new.request(method, params, path, headers)
    end

    def request(method, params, path = nil, headers = {})
      raise 'You need to configure GlobalRegistry with your access_token.' unless access_token

      url = if base_url.starts_with? 'http'
              Addressable::URI.parse(base_url)
            else
              Addressable::URI.parse("http://#{base_url}")
            end
      url.path = path || default_path
      url.query_values = headers.delete(:params) if headers[:params]

      case method
      when :post
        post_headers = default_headers.merge(content_type: :json, timeout: -1).merge(headers)
        RestClient.post(url.to_s, params.to_json, post_headers) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      when :put
        put_headers = default_headers.merge(content_type: :json, timeout: -1).merge(headers)
        RestClient.put(url.to_s, params.to_json, put_headers) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      else
        url.query_values = (url.query_values || {}).merge(params) if params.any?
        get_args = { method: method, url: url.to_s, timeout: -1,
                     headers: default_headers.merge(headers)
                   }
        RestClient::Request.execute(get_args) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      end
    end

    def default_path
      self.class.to_s.split('::').last.underscore.pluralize
    end

    def path_with_id(id)
      "#{default_path}/#{id}"
    end

    private

    def default_headers
      headers = { authorization: "Bearer #{access_token}", accept: :json }
      headers = headers.merge('X-Forwarded-For': @xff) if @xff.present?
      headers
    end

    def handle_response(response, request, result)
      case response.code
      when 200..299
        Oj.load(response)
      when 400
        raise RestClient::BadRequest, response
      when 404
        raise RestClient::ResourceNotFound, response
      when 500
        raise RestClient::InternalServerError, response
      else
        puts response.inspect
        puts request.inspect
        raise result.to_s
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
        break unless result['meta'] && result['meta']['next_page']
        page = result['meta']['page'].to_i + 1
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
      overall_result.delete('meta')
    end
  end
end
