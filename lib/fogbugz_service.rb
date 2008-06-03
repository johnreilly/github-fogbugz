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
    document = get(@api_uri, params)
    bad_logon = REXML::XPath.first(document.root, "//error")
    raise BadCredentials, "Bad credentials supplied to Fogbugz: #{bad_logon}" unless bad_logon.blank?
    REXML::XPath.first(document.root, "//token/text()").to_s
  end

  def implement(data)
    tell_fogbugz(:resolve, data, STATES[:implemented])
  end

  def fix(data)
    tell_fogbugz(:resolve, data, STATES[:fixed])
  end

  def complete(data)
    tell_fogbugz(:resolve, data, STATES[:completed])
  end

  def close(data)
    tell_fogbugz(:close, data)
  end

  def append_message(data)
    tell_fogbugz(:edit, data)
  end

  protected
  # Returns an REXML::Document to the specified URI
  def get(uri, params=nil)
    cmd = if params then
      "#{@curl} --data '#{params.to_query}' --silent '#{uri.to_s}'"
    else
      "#{@curl} --silent '#{uri.to_s}'"
    end

    puts cmd
    data = `#{cmd}`
    begin
      REXML::Document.new(data)
    rescue REXML::ParseException
      raise BadXml, "Could not parse response data:\n#{data}"
    end
  end

  def tell_fogbugz(operation, data, status=nil)
    params = {"cmd" => operation.to_s, "ixBug" => data[:case], "sEvent" => data[:message],
      "token" => @token}
    params["ixStatus"] = status if status
    get(@api_uri, params)
  end

  STATES = {:fixed => 2, :completed => 15, :implemented => 8}
end
