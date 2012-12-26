[![Build Status](https://secure.travis-ci.org/louismullie/open-nlp.png)](http://travis-ci.org/louismullie/open-nlp)

###About

This library provides high-level Ruby bindings to the Open NLP package, a Java machine learning toolkit for natural language processing (NLP). This gem is compatible with Ruby 1.9.2 and 1.9.3 as well as JRuby 1.7.1. It is tested on both Java 6 and Java 7.

###Installing

First, install the gem: `gem install open-nlp`. Then, download [the JARs and English language models](http://louismullie.com/treat/open-nlp-english.zip) in one package (80 MB).

Place the contents of the extracted archive inside the /bin/ folder of the `open-nlp` gem (e.g. [...]/gems/open-nlp-0.x.x/bin/).

Alternatively, from a terminal window, `cd` to the gem's folder and run:

```
wget http://www.louismullie.com/treat/open-nlp-english.zip
unzip -o open-nlp-english.zip -d bin/
```

Afterwards, you may individually download the appropriate models for other languages from the [open-nlp website](http://opennlp.sourceforge.net/models-1.5/).

###Configuring

After installing and requiring the gem (`require 'open-nlp'`), you may want to set some of the following configuration options.

```ruby
# Set an alternative path to look for the JAR files.
# Default is gem's bin folder.
OpenNLP.jar_path = '/path_to_jars/'

# Set an alternative path to look for the model files.
# Default is gem's bin folder.
OpenNLP.model_path = '/path_to_models/'

# Pass some alternative arguments to the Java VM.
# Default is ['-Xms512M', '-Xmx1024M'].
OpenNLP.jvm_args = ['-option1', '-option2']

# Redirect VM output to log.txt
OpenNLP.log_file = 'log.txt'

# Set default models for a language.
OpenNLP.use :language
```

###Examples


**Simple tokenizer**

```ruby
OpenNLP.load

sent = "The death of the poet was kept from his poems."
tokenizer = OpenNLP::SimpleTokenizer.new

tokens = tokenizer.tokenize(sent).to_a
# => %w[The death of the poet was kept from his poems .]
```

**Maximum entropy tokenizer, chunker and POS tagger**

```ruby

OpenNLP.load

chunker   = OpenNLP::ChunkerME.new
tokenizer = OpenNLP::TokenizerME.new
tagger    = OpenNLP::POSTaggerME.new

sent   = "The death of the poet was kept from his poems."

tokens = tokenizer.tokenize(sent).to_a
# => %w[The death of the poet was kept from his poems .]

tags   = tagger.tag(tokens).to_a
# => %w[DT NN IN DT NN VBD VBN IN PRP$ NNS .]

chunks = chunker.chunk(tokens, tags).to_a
# => %w[B-NP I-NP B-PP B-NP I-NP B-VP I-VP B-PP B-NP I-NP O]
```

**Abstract Bottom-Up Parser**

```ruby
OpenNLP.load

sent      = "The death of the poet was kept from his poems."
parser = OpenNLP::Parser.new
parse = parser.parse(sent)

parse.get_text.should eql sent

parse.get_span.get_start.should eql 0
parse.get_span.get_end.should eql 46
parse.get_child_count.should eql 1

child = parse.get_children[0]

child.text # => "The death of the poet was kept from his poems."
child.get_child_count # => 3
child.get_head_index #=> 5
child.get_type # => "S"
```

**Maximum Entropy Name Finder***

```ruby
OpenNLP.load

text = File.read('./spec/sample.txt').gsub!("\n", "")

tokenizer   = OpenNLP::TokenizerME.new
segmenter   = OpenNLP::SentenceDetectorME.new
ner_models  = ['person', 'time', 'money']

ner_finders = ner_models.map do |model|
  OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
end

sentences = segmenter.sent_detect(text)
named_entities = []

sentences.each do |sentence|

  tokens = tokenizer.tokenize(sentence)
  
  ner_models.each_with_index do |model,i|
    finder = ner_finders[i]
    name_spans = finder.find(tokens)
    name_spans.each do |name_span|
      start = name_span.get_start
      stop  = name_span.get_end-1
      slice = tokens[start..stop].to_a
      named_entities << [slice, model]
    end
  end

end
```

**Loading specific models**

Just pass the name of the model file to the constructor. The gem will search for the file in the `OpenNLP.model_path` folder.

```ruby
OpenNLP.load

tokenizer = OpenNLP::TokenizerME.new('en-token.bin')
tagger = OpenNLP::POSTaggerME.new('en-pos-perceptron.bin')
name_finder = OpenNLP::NameFinderME.new('en-ner-person.bin')
# etc.
```

**Loading specific classes**

You may want to load specific classes from the OpenNLP library that are not loaded by default. The gem provides an API to do this:

```ruby
# Default base class is opennlp.tools.
OpenNLP.load_class('SomeClassName')  
# => OpenNLP::SomeClassName

# Here, we specify another base class.
OpenNLP.load_class('SomeOtherClass', 'opennlp.tools.namefind')
# => OpenNLP::SomeOtherClass
```

**Contributing**

Fork the project and send me a pull request! Config updates for other languages are welcome.