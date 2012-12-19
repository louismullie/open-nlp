module OpenNLP
  
  # Library version.
   VERSION = '0.0.1'

   # Require configuration.
   require 'open-nlp/config'
  
  # ############################ #
  # BindIt Configuration Options #
  # ############################ #
  
   require 'bind-it'
   extend BindIt::Binding

  # The path in which to look for JAR files, with
  # a trailing slash (default is gem's bin folder).
  self.jar_path = File.dirname(__FILE__) + '/../bin/'
  
  # Load the JVM with a minimum heap size of 512MB,
  # and a maximum heap size of 1024MB.
  self.jvm_args = ['-Xms512M', '-Xmx1024M']
  
  # Turn logging off by default.
  self.log_file = nil
  
  # Default JARs to load.
  self.default_jars = [
    'jwnl-1.3.3.jar',
    'opennlp-tools-1.5.2-incubating.jar',
    'opennlp-maxent-3.0.2-incubating.jar',
    'opennlp-uima-1.5.2-incubating.jar'
  ]
  
  # Default namespace.
  self.default_namespace = 'opennlp.tools.'
  
  # Default classes.
  self.default_classes = [
    ['DocumentCategorizerME', 'opennlp.tools.doccat'],
    ['ChunkerME', 'opennlp.tools.chunker'],
    ['DictionaryDetokenizer', 'opennlp.tools.tokenize'],
    ['NameFinderME', 'opennlp.tools.namefind'],
    ['Parse', 'opennlp.tools.parser'],
    ['ParserFactory', 'opennlp.tools.parser'],
    ['POSTaggerME', 'opennlp.tools.postag'],
    ['SentenceDetectorME', 'opennlp.tools.sentdetect'],
    ['SimpleTokenizer', 'opennlp.tools.tokenize'],
    ['TokenizerME', 'opennlp.tools.tokenize']
  ]
  
  # Redefine the Bind-It class loader to redefine 
  # a new constructor for classes that require a model.
  def self.load_klass(klass, base, name = nil)
    super(klass,base,name)
    requires_model = OpenNLP::Config::RequiresModel
    return unless requires_model.include?(klass)
    new_class = Class.new(const_get(klass)) do
      def initialize(file = nil, *args)
        klass = OpenNLP.last_name(self.class)
        if !file && !OpenNLP.has_default_model?(klass)
          raise 'This class intentionally has no default ' +
          'model. Please supply a file name as an argument ' +
          'to the class constructor.'
        else
          model = OpenNLP.get_model(klass, file)
          super(*([model] + args))
        end
      end
    end
    remove_const(klass)
    const_set(klass, new_class)
  end
  
  # Make the bindings.
  self.bind
  
  # Load utility classes.
  self.load_class('FileInputStream', 'java.io')
  
  # ############################ #
  #   OpenNLP bindings proper    #
  # ############################ #

  class <<self
    # A hash containing loaded models.
    attr_accessor :models
    # A hash containing the names of loaded models.
    attr_accessor :model_files
    # The folder in which to look for models.
    attr_accessor :model_path
    # Store the language currently being used.
    attr_accessor :language
  end
  
  # The loaded models.
  self.models = {}
  
  # The names of loaded models.
  self.model_files = {}
  
  # The path to the main folder containing the folders
  # with the individual models inside. By default, this
  # is the same as the JAR path.
  self.model_path = self.jar_path
  
  # Default the language to English.
  self.language = :english
  
  # Use a given language for default models.
  def self.use(language)
    self.language = language
  end
  
  def self.set_model
    # Implement
  end

  def self.has_default_model?(klass)
    name = OpenNLP::Config::ClassToName[klass]
    if !OpenNLP::Config::DefaultModels[name]
      raise 'No default model files are available ' +
      "for the class #{klass}. Please supply a model " +
      'as an argument to the constructor.'
    end
    !OpenNLP::Config::DefaultModels[name].empty?
  end
  
  def self.get_model(klass, file=nil)
    name = OpenNLP::Config::ClassToName[klass]
    if !self.language and !file
      raise 'No model file was supplied to the ' +
      'constructor. Please supply a model file ' +
      'or call OpenNLP.use(:some_language), to ' +
      'load the default models for a language.'
    end
    OpenNLP.load_model(name, file)
    model = OpenNLP.models[name]
  end

  def self.load_model(name, file = nil)
    if self.models[name] && file ==
       self.model_files[name]
       return self.models[name]
    end
    models = Config::DefaultModels[name]
    file ||= models[self.language]
    path = self.model_path + file
    stream = FileInputStream.new(path)
    klass = Config::NameToClass[name]
    load_class(*klass)
    klass = const_get(klass[0])
    model = klass.new(stream)
    self.model_files[name] = file
    self.models[name] = model
  end

  def self.last_name(klass)
    klass.to_s.split('::')[-1]
  end
end