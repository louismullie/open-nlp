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


  def method_missing(sym, *args, &block)
    @proxy_inst.send(sym, *args, &block)
  end
  
  protected

  def get_list(tokens)
    list = OpenNLP::Bindings::ArrayList.new
    tokens.each do |t|
      list.add(OpenNLP::Bindings::String.new(t.to_s))
    end
    list
  end

end