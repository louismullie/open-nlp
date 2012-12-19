module OpenNLP::Config
  
  NameToClass = {
    categorizer: ['DoccatModel', 'opennlp.tools.doccat'],
    chunker: ['ChunkerModel', 'opennlp.tools.chunker'],
    detokenizer: ['DetokenizationDictionary', 'opennlp.tools.tokenize'],
    name_finder: ['TokenNameFinderModel', 'opennlp.tools.namefind'],
    parser: ['ParserModel', 'opennlp.tools.parser'],
    pos_tagger: ['POSModel', 'opennlp.tools.postag'],
    sentence_detector: ['SentenceModel', 'opennlp.tools.sentdetect'],
    tokenizer: ['TokenizerModel', 'opennlp.tools.tokenize']
  }
  
  ClassToName = {
    'ChunkerME' => :chunker,
    'DictionaryDetokenizer' => :detokenizer,
    'DocumentCategorizerME' => :categorizer,
    'NameFinderME' => :name_finder,
    'POSTaggerME' => :pos_tagger,
    'ParserME' => :parser,
    'SentenceDetectorME' => :sentence_detector,
    'TokenizerME' => :tokenizer,
  }

  DefaultModels = {
    chunker: {
      english: 'en-chunker.bin'
    },
    detokenizer: {
      english: 'en-detokenizer.xml'
    },
    # Intentionally left empty.
    name_finder: {},
    parser: {
      english: 'en-parser-chunking.bin'
    },
    pos_tagger: { 
      english: 'en-pos-maxent.bin'
    },
    sentence_detector: {
      english: 'en-sent.bin'
    },
    tokenizer: {
      english: 'en-token.bin'
    }
  }

  # Classes that require a model as first argument to constructor.
  RequiresModel = [
    'SentenceDetectorME', 'NameFinderME', 'DictionaryDetokenizer',
    'TokenizerME', 'ChunkerME', 'POSTaggerME'
  ]

  
end