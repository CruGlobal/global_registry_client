require 'rest-client'
require 'oj'
require 'retryable'

module GlobalRegistry
  class Base

    def self.find(id, params = {})
      request(:get, params, path_with_id(id))
    end

    def self.get(params = {})
      request(:get, params)
    end

    def self.post(params = {})
      request(:post, params)
    end

    def self.put(id, params = {})
      request(:put, params, path_with_id(id))
    end

    def self.delete(id)
      request(:delete, {}, path_with_id(id))
    end

    def self.delete_or_ignore(id)
      begin
        delete(id)
      rescue RestClient::Exception => e
        unless e.response.code.to_i == 404
          raise
        end
      end
    end


    def self.request(method, params, path = nil)
      raise 'You need to configure GlobalRegistry with your access_token.' unless GlobalRegistry.access_token

      path ||= default_path
      url = GlobalRegistry.base_url
      url += '/' unless url.last == '/'
      url += path

      case method
      when :post
        RestClient.post(url, params.to_json, :content_type => :json, :accept => :json, authorization: "Bearer #{GlobalRegistry.access_token}", :timeout => -1) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      when :put
        RestClient.put(url, params.to_json, :content_type => :json, :accept => :json, authorization: "Bearer #{GlobalRegistry.access_token}", :timeout => -1) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      else
        RestClient::Request.execute(:method => method, :url => url, :headers => {params: params, authorization: "Bearer #{GlobalRegistry.access_token}", :accept => :json}, :timeout => -1) { |response, request, result, &block|
          handle_response(response, request, result)
        }
      end
    end

    def self.handle_response(response, request, result)
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

    def self.default_path
      to_s.split('::').last.underscore.pluralize
    end

    def self.path_with_id(id)
      "#{default_path}/#{id}"
    end

  end
end




