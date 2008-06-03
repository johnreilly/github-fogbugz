class MessageParser
  %%{
    machine message_parser_machine;

    bugid = ('#' [1-9] [0-9]*);

    closes = (/close/i ([sS])?);
    completes = (/complete/i ([sS])?);
    references = (/reference/i ([sS])?);
    fixes = ((/re/i)? /fix/i (/ed/i | (/es/i))?);
    reopens = (/reopen/i ([sS])?);
    implements = ((/re/i)? /implement/i ([sS])?);
    keywords = (closes | completes | references | fixes | reopens | implements);
    main := |*
              (closes) => { listener.close };
              (completes) => { listener.complete };
              (references) => { listener.reference };
              (fixes) => { listener.fix };
              (reopens) => { listener.reopen };
              (implements) => { listener.implement };
              (bugid) => { listener.case(data[ts+1...te].pack("C*")) };
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
