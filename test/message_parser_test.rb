require File.dirname(__FILE__) + "/test_helper"
require "message_parser"

class MessageParserTest < Test::Unit::TestCase
  def setup
    @listener = mock("listener")
  end

  def test_parse_message_without_fogbugz_data
    assert_nothing_raised do
      MessageParser.parse("this is a test", @listener)
    end
  end

  def test_parse_message_with_reference_to_case_notifies_listener_about_case
    @listener.expects(:reference)
    @listener.expects(:case).with("1231").once
    MessageParser.parse("This is a test.  References #1231", @listener)
  end

  def test_parse_message_with_closing_case_notifies_listener
    @listener.expects(:close)
    @listener.expects(:case).with("3321").once
    MessageParser.parse("Closes #3321", @listener)
  end

  def test_parse_fixes_with_two_cases_notifies_listener
    @listener.expects(:fix)
    @listener.expects(:case).with("3321").once
    @listener.expects(:case).with("1234").once
    MessageParser.parse("Fixes #3321, #1234", @listener)
  end

  def test_parse_reopens
    @listener.expects(:reopen)
    @listener.expects(:case).with("1234").once
    MessageParser.parse("Reopens #1234", @listener)
  end

  def test_parse_implements
    @listener.expects(:implement)
    @listener.expects(:case).with("1334").once
    MessageParser.parse("Implements #1334", @listener)
  end

  def test_parse_completes
    @listener.expects(:complete)
    @listener.expects(:case).with("1334").once
    MessageParser.parse("Completes #1334", @listener)
  end
end
