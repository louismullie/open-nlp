class OpenNLP::Base

  def initialize(file_or_arg=nil, *args)

    @proxy_class = OpenNLP::Bindings.const_get(last_name)

    if requires_model?
      if !file_or_arg && !has_default_model?
        raise "No default model files are available for " +
        "class #{last_name}. Please supply a model as" +
        "an argument to the constructor."
      end
      @model = OpenNLP::Bindings.get_model(last_name, file_or_arg)
      @proxy_inst = @proxy_class.new(*([@model] + args))
    else
      @proxy_inst = @proxy_class.new(*([*file_or_arg] + args))
    end

  end

  def has_default_model?
    name = OpenNLP::Config::ClassToName[last_name]
    !OpenNLP::Config::DefaultModels[name].empty?
  end

  def requires_model?
    OpenNLP::Config::RequiresModel.include?(last_name)
  end

  def last_name
    self.class.to_s.split('::')[-1]
  end

  def self.get_list(tokens)
    list = OpenNLP::ArrayList.new
    tokens.each do |t|
      list.add(OpenNLP::String.new(t.to_s))
    end
    list
  end

  protected

  if RUBY_PLATFORM =~ /java/

    def method_missing(sym, *args, &block)
      @proxy_inst.send(sym, *args, &block)
    end

  else

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

  end

end
