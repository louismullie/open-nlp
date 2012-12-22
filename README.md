[![Build Status](https://secure.travis-ci.org/louismullie/open-nlp.png)](http://travis-ci.org/louismullie/open-nlp)

**About**

This library provides high-level Ruby bindings to the Open NLP package, a Java machine learning toolkit for natural language processing (NLP). 

This gem only provides a thin wrapper over the OpenNLP API. If you are looking for a Ruby natural language processing framework, have a look at [Treat](https://github.com/louismullie/treat).

**Installing**

__Note: If you are running on MRI, this gem will use the Ruby-Java Bridge (Rjb), which currently does not support Java 7. Therefore, if you have installed Java 7, you should set your JAVA_HOME to point to your old Java 6 install before installing Rjb; for example, `export "JAVA_HOME=/usr/lib/jvm/java-6-openjdk/"`.__

First, install the gem: `gem install open-nlp`. Then, individually download the appropriate models from the [open-nlp website](http://opennlp.sourceforge.net/models-1.5/) or just get [all english language models](louismullie.com/treat/open-nlp-english.zip) in one package (80 MB).

Place the contents of the extracted archive inside the /bin/ folder of the open-nlp gem (e.g. [...]/gems/open-nlp-0.x.x/bin/).

**Configuration**

After installing and requiring the gem (`require 'open-nlp'`), you may want to set some optional configuration options. Here are some examples:

```ruby
# Set an alternative path to look for the JAR files
# Default is gem's bin folder.
OpenNLP.jar_path = '/path_to_jars/'

# Set an alternative path to look for the model files
# Default is gem's bin folder.
OpenNLP.model_path = '/path_to_models/'

# Pass some alternative arguments to the Java VM.
# Default is ['-Xms512M', '-Xmx1024M'].
OpenNLP.jvm_args = ['-option1', '-option2']

# Redirect VM output to log.txt
OpenNLP.log_file = 'log.txt'

# WARNING: Not implemented yet.

# Use the model files for a different language than English.
# OpenNLP.use(:french) # or :german
# 
# Change a specific model file.
# OpenNLP.set_model('pos.model', 'english-left3words-distsim.tagger')
```

**Using the gem**

```ruby
text = 'Angela Merkel met Nicolas Sarkozy on January 25th in ' +
       'Berlin to discuss a new $25 billion austerity package.' +
       'Sarkozy looked pleased, but Merkel was dismayed.'

tokenizer   = OpenNLP::TokenizerME.new
segmenter   = OpenNLP::SentenceDetectorME.new
tagger      = OpenNLP::POSTaggerME.new
ner_models  = ['person', 'time', 'money']

ner_finders = ner_models.map do |model|
 OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
end

sentences = segmenter.sent_detect(text)
all_entities = []

sentences.each do |sentence|

 tokens = tokenizer.tokenize(sentence)
 tags   = tagger.tag(tokens)
 
 # Get a list of all tokens.
 puts tokens.to_a.inspect
 # Get the sentence's text.
 puts sentence.to_s.inspect
 # Get the sentence's tags.
 puts tags.to_a.inspect

 # Run three NER models and find entities.
 ner_models.each_with_index do |model,i|
   finder = ner_finders[i]
   name_spans = finder.find(tokens)
   name_spans.each do |name_span|
     start = name_span.get_start
     stop  = name_span.get_end-1
     slice = tokens[start..stop].to_a
     all_entities << [slice, model]
   end
 end

end

# Show all named entities.
puts all_entities.inspect
```

**Loading specific classes**

You may also want to load your own classes from the Stanford NLP to do more specific tasks. The gem provides an API to do this:

```ruby
# Default base class is opennlp.tools.
OpenNLP.load_class('SomeClassName')  

# Here, we specify another base class.
OpenNLP.load_class('SomeOtherClass', 'opennlp.tools.namefind') 
```

**Contributing**

Feel free to fork the project and send me a pull request!