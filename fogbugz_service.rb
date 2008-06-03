require "uri"
require "open-uri"
require "rexml/document"
require "rexml/xpath"
require "activesupport"

class FogbugzService
  class FogbugzError < RuntimeError; end
  class ClientOutOfDate < FogbugzError; end
  class BadXml < FogbugzError; end
  class BadCredentials < FogbugzError; end

  attr_reader :root_uri, :api_uri

  def initialize(root)
    @root_uri = root.respond_to?(:scheme) ? root : URI.parse(root)
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
    document = get(@api_uri.merge("?#{params.to_query}"))
    bad_logon = REXML::XPath.first(document.root, "//error")
    raise BadCredentials, "Bad credentials supplied to Fogbugz: #{bad_logon}" unless bad_logon.blank?
    REXML::XPath.first(document.root, "//token/text()").to_s
  end

  protected
  # Returns an REXML::Document to the specified URI
  def get(uri)
    data = open(uri)
    begin
      REXML::Document.new(data.read)
    rescue REXML::ParseException
      raise BadXml, "Could not parse response data:\n#{data.read}"
    end
  end
end
