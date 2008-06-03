class MessageParser
  %%{
    machine message_parser_machine;

    bugid = ('#' [1-9] [0-9]*);

    closes = (/close/i ([sS])?);
    references = (/reference/i ([sS])?);
    fixes = ((/re/i)? /fix/i (/ed/i | (/es/i))?);
    reopens = (/reopen/i ([sS])?);
    reactivates = (/reactivate/i ([sS])?);
    implements = ((/re/i)? /implement/i ([sS])?);
    keywords = (closes | references | fixes | reopens | reactivates | implements);
    main := |*
              (closes) => { listener.close };
              (references) => { listener.reference };
              (fixes) => { listener.fix };
              (reopens) => { listener.reopen };
              (reactivates) => { listener.reactivate };
              (implements) => { listener.implement };
              (bugid) => { listener.case(data[ts...te].pack("C*")) };
              ('.') => { listener.reference };
              (any - (bugid | keywords));
            *|;
  }%%

  %%write data;

  class << self
    def parse(msg, listener)
      data = msg.unpack("C*")
      eof = data.length

      bugid, action, name = nil

      %%write init;
      %%write exec;
    end
  end
end
