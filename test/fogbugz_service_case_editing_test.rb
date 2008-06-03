require File.dirname(__FILE__) + "/test_helper"
require "fogbugz_service"

class FogbugzServiceCaseEditingTest < Test::Unit::TestCase
  TOKEN = "andf09j"

  def setup
    @service_uri = URI.parse("http://fogbugz.my-service.com/")
    @service = FogbugzService.new(@service_uri, "/path/to/curl", TOKEN)
    @service.stubs(:get).returns(REXML::Document.new(VALID_API_RESPONSE))
    @uri = @service.validate!
  end

  def test_implement_calls_fogbugz_with_cmd_set_to_resolve_and_status_set_to_implement
    params = {"cmd" => "resolve", "ixBug" => "2211", "ixStatus" => FogbugzService::STATES[:implemented],
        "sEvent" => "this is the message", "token" => TOKEN}
    @service.expects(:get).with(@uri, params).returns(REXML::Document.new(VALID_EDIT_RESPONSE))
    @service.implement(:case => "2211", :message => "this is the message")
  end

  def test_fix_calls_fogbugz_with_cmd_set_to_resolve_and_status_set_to_fixed
    params = {"cmd" => "resolve", "ixBug" => "2211", "ixStatus" => FogbugzService::STATES[:fixed],
        "sEvent" => "this is the message", "token" => TOKEN}
    @service.expects(:get).with(@uri, params).returns(REXML::Document.new(VALID_EDIT_RESPONSE))
    @service.fix(:case => "2211", :message => "this is the message")
  end

  def test_complete_calls_fogbugz_with_cmd_set_to_resolve_and_status_set_to_completed
    params = {"cmd" => "resolve", "ixBug" => "2211", "ixStatus" => FogbugzService::STATES[:completed],
        "sEvent" => "this is the message", "token" => TOKEN}
    @service.expects(:get).with(@uri, params).returns(REXML::Document.new(VALID_EDIT_RESPONSE))
    @service.complete(:case => "2211", :message => "this is the message")
  end

  def test_close_calls_fogbugz_with_cmd_set_to_close
    params = {"cmd" => "close", "ixBug" => "2211",
        "sEvent" => "this is the message", "token" => TOKEN}
    @service.expects(:get).with(@uri, params).returns(REXML::Document.new(VALID_EDIT_RESPONSE))
    @service.close(:case => "2211", :message => "this is the message")
  end

  def test_append_message_calls_fogbugz_with_cmd_set_to_edit
    params = {"cmd" => "edit", "ixBug" => "2211",
        "sEvent" => "this is the message", "token" => TOKEN}
    @service.expects(:get).with(@uri, params).returns(REXML::Document.new(VALID_EDIT_RESPONSE))
    @service.append_message(:case => "2211", :message => "this is the message")
  end

  VALID_API_RESPONSE = <<-API
<?xml version="1.0" encoding="UTF-8" ?>
<response>
<version>3</version>
<minversion>1</minversion>
<url>api.asp?</url>
</response>
API

  VALID_EDIT_RESPONSE = <<-API
  <?xml version="1.0" encoding="UTF-8" ?>
API
end
