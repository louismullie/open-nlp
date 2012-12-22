module OpenNLP

  # Library version.
  VERSION = '0.0.1'

  # Require Java bindings.
  require 'open-nlp/bindings'
  OpenNLP::Bindings.bind
  
  # Require Ruby wrappers.
  require 'open-nlp/classes'
  
  # Load a Java class into the OpenNLP
  # namespace (e.g. OpenNLP::Loaded).
  def load_class(*args)
    OpenNLP::Bindings.load_class(*args)
  end
  
  # Forwards the handling of missing
  # constants to the Bindings class.
  def const_missing(const)
    OpenNLP::Bindings.const_get(const)
  end

end
