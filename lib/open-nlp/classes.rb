require 'open-nlp/base'

class OpenNLP::SentenceDetectorME < OpenNLP::Base
  unless RUBY_PLATFORM =~ /java/
    def sent_detect(*args)
      invoke_with_sig(:sent_detect, args)
    end
  end
end

class OpenNLP::SimpleTokenizer < OpenNLP::Base; end

class OpenNLP::TokenizerME < OpenNLP::Base
  unless RUBY_PLATFORM =~ /java/
    def tokenize(*args)
      invoke_with_sig(:tokenize, args)
    end
  end
end

class OpenNLP::POSTaggerME < OpenNLP::Base
    
  unless RUBY_PLATFORM =~ /java/
    def tag(*args)
      OpenNLP::Bindings::Utils
      .tagWithArrayList(@proxy_inst, args[0])
    end
  end
  
end

class OpenNLP::ChunkerME < OpenNLP::Base

  if RUBY_PLATFORM =~ /java/

    def chunk(tokens, tags)
      if !tokens.is_a?(Array)
        tokens = tokens.to_a
        tags = tags.to_a
      end
      tokens = tokens.to_java(:String)
      tags = tags.to_java(:String)
      @proxy_inst.chunk(tokens,tags).to_a
    end

  else

    def chunk(tokens, tags)
      chunks = OpenNLP::Bindings::Utils.chunkWithArrays(@proxy_inst, tokens,tags)
      chunks.map { |c| c.to_s }
    end

  end

end

class OpenNLP::Parser < OpenNLP::Base


  def parse(text)

    tokenizer = OpenNLP::TokenizerME.new
    full_span = OpenNLP::Bindings::Span.new(0, text.size)

    parse_obj = OpenNLP::Bindings::Parse.new(
    text, full_span, "INC", 1, 0)

    tokens = tokenizer.tokenize_pos(text)

    tokens.each_with_index do |tok,i|
      start, stop = tok.get_start, tok.get_end
      token = text[start..stop-1]
      span = OpenNLP::Bindings::Span.new(start, stop)
      parse = OpenNLP::Bindings::Parse.new(text, span, "TK", 0, i)
      parse_obj.insert(parse)
    end

    @proxy_inst.parse(parse_obj)

  end

end

class OpenNLP::NameFinderME < OpenNLP::Base
  unless RUBY_PLATFORM =~ /java/
    def find(*args)
      OpenNLP::Bindings::Utils
      .findWithArrayList(@proxy_inst, args[0])
    end
  end
end
