require "uri"
require "rexml/document"
require "rexml/xpath"
require "activesupport"

class FogbugzService
  class FogbugzError < RuntimeError; end
  class ClientOutOfDate < FogbugzError; end
  class BadXml < FogbugzError; end
  class BadCredentials < FogbugzError; end

  attr_reader :root_uri, :api_uri

  def initialize(root, curl, token=nil)
    @root_uri = root.respond_to?(:scheme) ? root : URI.parse(root)
    @curl = curl
    @token = token
  end

  def validate!
    document = get(@root_uri.merge("api.xml"))
    raise BadXml, "Did not find the expected root response element.  Instead, I found:\n#{document.root}" unless document.root.name == "response"

    minversion = REXML::XPath.first(document.root, "//minversion/text()").to_s
    raise ClientOutOfDate, "This client expected to find a minversion <= 3 in the api.xml file.  Instead it found #{minversion.inspect}" unless minversion.to_i <= 3

    relative_path = REXML::XPath.first(document.root, "//url/text()")
    @api_uri = @root_uri.merge(relative_path.to_s)
  end

  def connect
    validate!
    yield self
  end

  def logon(email, password)
    params = {"cmd" => "logon", "email" => email, "password" => password}
    uri = @api_uri.dup
    uri.query = params.to_query
    document = get(uri)
    bad_logon = REXML::XPath.first(document.root, "//error")
    raise BadCredentials, "Bad credentials supplied to Fogbugz: #{bad_logon}" unless bad_logon.blank?
    REXML::XPath.first(document.root, "//token/text()").to_s
  end

  def implement(data)
    uri = @api_uri.dup
    uri.query = {"cmd" => "resolve", "ixBug" => data[:case], "sEvent" => data[:message],
      "ixStatus" => STATES[:implemented], "token" => @token}.to_query
    get(uri)
  end

  def fix(data)
    uri = @api_uri.dup
    uri.query = {"cmd" => "resolve", "ixBug" => data[:case], "sEvent" => data[:message],
      "ixStatus" => STATES[:fixed], "token" => @token}.to_query
    get(uri)
  end

  def complete(data)
    uri = @api_uri.dup
    uri.query = {"cmd" => "resolve", "ixBug" => data[:case], "sEvent" => data[:message],
      "ixStatus" => STATES[:completed], "token" => @token}.to_query
    get(uri)
  end

  def close(data)
    uri = @api_uri.dup
    uri.query = {"cmd" => "close", "ixBug" => data[:case], "sEvent" => data[:message],
      "token" => @token}.to_query
    get(uri)
  end

  def append_message(data)
    uri = @api_uri.dup
    uri.query = {"cmd" => "edit", "ixBug" => data[:case], "sEvent" => data[:message],
      "token" => @token}.to_query
    get(uri)
  end

  protected
  # Returns an REXML::Document to the specified URI
  def get(uri)
    cmd = "#{@curl} --silent '#{uri.to_s}'"
    puts cmd
    data = `#{cmd}`
    begin
      REXML::Document.new(data)
    rescue REXML::ParseException
      raise BadXml, "Could not parse response data:\n#{data}"
    end
  end

  STATES = {:fixed => 2, :completed => 15, :implemented => 8}
end
