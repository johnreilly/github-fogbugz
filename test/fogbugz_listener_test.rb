require File.dirname(__FILE__) + "/test_helper"
require "fogbugz_listener"

class FogbugzListenerTest < Test::Unit::TestCase
  def setup
    @service = mock("fogbugz-service")
  end

  def test_accumulates_fix_plus_case_and_post
    @listener = FogbugzListener.new(:sha1 => "a1231", :message => "The full commit message, fixes #1111.")
    @listener.fix
    @listener.case("1111")
    @service.expects(:fix).with(:case => "1111", :message => "The full commit message, fixes #1111.\n\nCommit: a1231")
    @listener.update_fogbugz(@service)
  end

  def test_accumulates_reopen_plus_case_and_post
    @listener = FogbugzListener.new(:sha1 => "c829a13", :message => "Reopens #3211")
    @listener.reopen
    @listener.case("3211")
    @service.expects(:reopen).with(:case => "3211", :message => "Reopens #3211\n\nCommit: c829a13")
    @listener.update_fogbugz(@service)
  end

  def test_accumulates_implement_two_cases_and_post
    @listener = FogbugzListener.new(:sha1 => "c829a13", :message => "Implements #3322 and #7219")
    @listener.implement
    @listener.case("3322")
    @listener.case("7219")
    @service.expects(:implement).with(:case => "3322", :message => "Implements #3322 and #7219\n\nCommit: c829a13")
    @service.expects(:implement).with(:case => "7219", :message => "Implements #3322 and #7219\n\nCommit: c829a13")
    @listener.update_fogbugz(@service)
  end

  def test_adds_link_to_github_in_message_if_repo_in_options
    @listener = FogbugzListener.new(:sha1 => "c829a13", :message => "Reopens #3211", :commit_url => "http://github.com/johnreilly/github-fogbuz")
    @listener.reopen
    @listener.case("3211")
    @service.expects(:reopen).with(:case => "3211", :message => "Reopens #3211\n\nCommit: c829a13\nhttp://github.com/johnreilly/github-fogbuz/commit/c829a13")
    @listener.update_fogbugz(@service)
  end

  def test_reference_adds_extra_text_to_link_cases_together
    @listener = FogbugzListener.new(:sha1 => "c829a13", :message => "Implements #1112, references #9219, #9220", :commit_url => "http://github.com/johnreilly/github-fogbuz")
    @listener.implement
    @listener.case("1112")
    @listener.reference
    @listener.case("9219")
    @listener.case("9220")
    @service.expects(:implement).with(:case => "1112",
        :message => "Implements #1112, references #9219, #9220\n\nReferences case 9219, case 9220\nCommit: c829a13\nhttp://github.com/johnreilly/github-fogbuz/commit/c829a13")
    @listener.update_fogbugz(@service)
  end

  def test_reference_only_adds_message_to_proper_case
    @listener = FogbugzListener.new(:sha1 => "c829a13", :message => "References #3211", :commit_url => "http://github.com/johnreilly/github-fogbuz/commit/c829a13")
    @listener.reference
    @listener.case("3211")
    @service.expects(:append_message).with(:case => "3211", :message => "References #3211\n\nCommit: c829a13\nhttp://github.com/johnreilly/github-fogbuz/commit/c829a13")
    @listener.update_fogbugz(@service)
  end
end
