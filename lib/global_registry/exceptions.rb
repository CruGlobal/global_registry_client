module GlobalRegistry # :nodoc:
  class BadRequest < ::RestClient::BadRequest; end

  class ResourceNotFound < ::RestClient::ResourceNotFound; end

  class InternalServerError < ::RestClient::InternalServerError; end

  class OtherError < ::RestClient::Exception; end

  EXCEPTIONS = [BadRequest, ResourceNotFound, InternalServerError, OtherError].freeze
end
