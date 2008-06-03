require File.dirname(__FILE__) + "/test_helper"
require "fogbugz_service"

class FogbugzServiceLogonTest < Test::Unit::TestCase
  def setup
    @service_uri = URI.parse("http://fogbugz.my-service.com/")
    @service = FogbugzService.new(@service_uri)
    @service.stubs(:get).returns(REXML::Document.new(VALID_API_RESPONSE))
    @uri = @service.validate!
  end

  def test_logon_calls_fogbugz_to_retrieve_token
    params = {"cmd" => "logon", "email" => "me@my-domain.com", "password" => "my-super-duper-password"}.to_query
    @service.expects(:get).with(@uri.merge("?#{params}")).returns(REXML::Document.new(VALID_LOGON_RESPONSE))
    @service.logon("me@my-domain.com", "my-super-duper-password")
  end

  def test_logon_returns_token
    @service.stubs(:get).returns(REXML::Document.new(VALID_LOGON_RESPONSE))
    assert_equal "24dsg34lok43un23", @service.logon("me@my-domain.com", "my-super-duper-password")
  end

  def test_logon_raises_bad_credentials_when_logon_fails
    @service.stubs(:get).returns(REXML::Document.new(FAILED_LOGON_RESPONSE))
    assert_raise FogbugzService::BadCredentials do
      @service.logon("me@my-domain.com", "my-super-duper-password")
    end
  end

  VALID_API_RESPONSE = <<-API
<?xml version="1.0" encoding="UTF-8" ?>
<response>
<version>3</version>
<minversion>1</minversion>
<url>api.asp?</url>
</response>
  API

  VALID_LOGON_RESPONSE = <<-API
<?xml version="1.0" encoding="UTF-8" ?>
<response><token>24dsg34lok43un23</token></response>
  API

  FAILED_LOGON_RESPONSE = <<-API
<response><error code="1">Error Message To Show User</error></response>
  API
end
