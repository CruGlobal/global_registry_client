module GlobalRegistry # :nodoc:
  class BadRequest < ::Faraday::BadRequestError; end

  class ResourceNotFound < ::Faraday::ResourceNotFound; end

  class InternalServerError < ::Faraday::ServerError; end

  class OtherError < ::Faraday::Error; end

  EXCEPTIONS = [BadRequest, ResourceNotFound, InternalServerError, OtherError].freeze
end
