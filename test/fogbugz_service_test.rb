require File.dirname(__FILE__) + "/test_helper"
require "fogbugz_service"

class FogbugzServiceTest < Test::Unit::TestCase
  def setup
    @service_uri = URI.parse("http://fogbugz.my-service.com/")
    @service = FogbugzService.new(@service_uri)
  end

  def test_validate_connects_to_fogbugz_and_retrieves_the_api_url
    @service.expects(:get).with(@service_uri.merge("api.xml")).returns(REXML::Document.new(VALID_API_RESPONSE))
    @service.validate!
  end

  def test_validate_parses_response_to_find_url
    @service.stubs(:get).returns(REXML::Document.new(VALID_API_RESPONSE))
    @service.validate!
    assert_equal @service_uri.merge("api.asp?"), @service.api_uri
  end

  def test_validate_raises_if_minimum_version_is_not_one
    @service.stubs(:get).returns(REXML::Document.new(RECENT_API_RESPONSE))
    assert_raise(FogbugzService::ClientOutOfDate) do
      @service.validate!
    end
  end

  def test_validate_raises_if_xhtml_returned
    @service.stubs(:get).returns(REXML::Document.new(VALID_XHTML_RESPONSE))
    assert_raise(FogbugzService::BadXml) do
      @service.validate!
    end
  end

  def test_validate_does_validation_only_once
    @service.expects(:get).once.returns(REXML::Document.new(VALID_API_RESPONSE))
    @service.validate!
  end

  VALID_API_RESPONSE = <<-API
    <?xml version="1.0" encoding="UTF-8" ?>
    <response>
    <version>3</version>
    <minversion>1</minversion>
    <url>api.asp?</url>
    </response>
  API

  RECENT_API_RESPONSE = <<-API
  <?xml version="1.0" encoding="UTF-8" ?>
   <response>
    <version>9</version>
    <minversion>7</minversion>
    <url>api.asp?</url>
   </response>
  API

  VALID_XHTML_RESPONSE = <<-API
    <html>
    <head>
        <title>Fogbugz API</title>
      </head>
      <body>
      </body>
    </html>
  API
end
