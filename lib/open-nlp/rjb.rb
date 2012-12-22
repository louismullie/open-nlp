
  def initialize(file = nil, *args)
    klass = OpenNLP.last_name(self.class)
    @proxy_class = OpenNLP.const_get(klass+'_Java')
    if !file && !OpenNLP.has_default_model?(klass)
      raise 'This class intentionally has no default ' +
      'model. Please supply a file name as an argument ' +
      'to the class constructor.'
    else
      model = OpenNLP.get_model(klass, file)
      @proxy_inst = @proxy_class.new(*([model] + args))
    end
  end
  def method_missing(sym, *args, &block)
    if sym == :tag
      arg = Utils.getStringArray(args[0])
      r = @proxy_inst.send(sym, arg)
    else
      r = @proxy_inst.send(sym, *args)
    end
    return r

    r = nil
    if [:sent_detect, :tokenize, :tag].include?(sym)
      r = @proxy_inst._invoke(sym.to_s, 'Ljava.lang.String;', *args)
    elsif sym == :find
      r = @proxy_inst.send(sym, *args)
    else
      puts @proxy_inst.java_methods.inspect
      puts sym.inspect
    end
    if [:tokenize].include?(sym)
      r = OpenNLP.get_list(r)
    end
    return r

  end
