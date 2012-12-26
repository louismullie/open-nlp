module OpenNLP

  # Library version.
  VERSION = '0.1.2'

  # Require Java bindings.
  require 'open-nlp/bindings'
  
  # Require Ruby wrappers.
  require 'open-nlp/classes'
  
  # Setup the JVM and load the default JARs.
  def self.load
    OpenNLP::Bindings.bind
  end

  # Load a Java class into the OpenNLP
  # namespace (e.g. OpenNLP::Loaded).
  def self.load_class(*args)
    OpenNLP::Bindings.load_class(*args)
  end
  
  # Forwards the handling of missing
  # constants to the Bindings class.
  def self.const_missing(const)
    OpenNLP::Bindings.const_get(const)
  end
  
  # Forward the handling of missing 
  # methods to the Bindings class.
  def self.method_missing(sym, *args, &block)
    OpenNLP::Bindings.send(sym, *args, &block)
  end

end