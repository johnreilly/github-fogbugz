class FogbugzListener
  attr_reader :options

  def initialize(options={})
    @options = options
    @state = :invalid
    @actions = Hash.new {|h, k| h[k] = Array.new}
  end

  def fix
    @state = :fix
  end

  def implement
    @state = :implement
  end

  def reopen
    @state = :reopen
  end

  def close
    @state = :close
  end

  def reference
    @state = :reference
  end

  def case(bugid)
    @actions[@state] << bugid
  end

  def update_fogbugz(service)
    message = options[:message].dup
    references = @actions.delete(:reference)
    message << "\n"

    if @actions.empty? then
      message << "\nCommit: #{options[:sha1]}"
      message << "\n#{options[:commit_url]}" if options[:commit_url]
      references.each do |bugid|
        service.append_message(:case => bugid, :message => message)
      end
    else
      message << "\nReferences " << references.map {|bugid| "case #{bugid}"}.join(", ") if references && !references.empty?
      message << "\nCommit: #{options[:sha1]}"
      message << "\n#{options[:commit_url]}/commit/#{options[:sha1]}" if options[:commit_url]
      @actions.each_pair do |action, bugids|
        bugids.each do |bugid|
          service.send(action, :case => bugid, :message => message)
        end
      end
    end
  end
end
