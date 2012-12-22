# encoding: utf-8
require_relative 'spec_helper'

describe OpenNLP do
  
  context "when an unreachable jar_path or model_path is provided" do
    it "raises an exception when trying to load" do
      OpenNLP.jar_path = '/unreachable/'
      OpenNLP::Bindings.jar_path.should eql '/unreachable/'
      OpenNLP.model_path = '/unreachable/'
      OpenNLP::Bindings.model_path.should eql '/unreachable/'
      expect { OpenNLP.load }.to raise_exception
      OpenNLP.jar_path = OpenNLP.model_path = OpenNLP.default_path
      expect { OpenNLP.load }.not_to raise_exception
    end
  end
  
  context "when a constructor is provided with a specific model to load" do
    it "loads that model, looking for the supplied file relative to OpenNLP.model_path " do
      
      OpenNLP.load
      
      tokenizer = OpenNLP::TokenizerME.new('en-token.bin')
      tagger = OpenNLP::POSTaggerME.new('en-pos-perceptron.bin')

      sent = "The death of the poet was kept from his poems."
      tokens = tokenizer.tokenize(sent)
      tags = tagger.tag(tokens)
      
      OpenNLP.models[:pos_tagger].get_pos_model.to_s
      .index('opennlp.perceptron.PerceptronModel').should_not be_nil
      
      tags.should eql ["DT", "NN", "IN", "DT", "NN", "VBD", "VBN", "IN", "PRP$", "NNS", "."]

    end
  end

  context "when a class is loaded through the #load_class method" do
    it "loads the class and allows to access it through the global namespace" do
      OpenNLP.load_class('ChunkSample', 'opennlp.tools.chunker')
      expect { OpenNLP::ChunkSample }.not_to raise_exception
    end
  end

  context "the maximum entropy chunker is run after tokenization and POS tagging" do
    it "should find the accurate chunks" do
      
      OpenNLP.load
      
      chunker   = OpenNLP::ChunkerME.new
      tokenizer = OpenNLP::TokenizerME.new
      tagger    = OpenNLP::POSTaggerME.new

      sent   = "The death of the poet was kept from his poems."
      tokens = tokenizer.tokenize(sent)
      tags   = tagger.tag(tokens)
      
      chunks = chunker.chunk(tokens, tags)

      chunks.to_a.should eql %w[B-NP I-NP B-PP B-NP I-NP B-VP I-VP B-PP B-NP I-NP O]
      tokens.to_a.should eql %w[The death of the poet was kept from his poems .]
      tags.to_a.should eql %w[DT NN IN DT NN VBD VBN IN PRP$ NNS .]
      
    end
  end

  context "the maximum entropy parser is run after tokenization" do
    it "parses the text accurately" do
      
      OpenNLP.load
      
      sent      = "The death of the poet was kept from his poems."
      parser = OpenNLP::Parser.new
      parse = parser.parse(sent)

      parse.get_text.should eql sent

      parse.get_span.get_start.should eql 0
      parse.get_span.get_end.should eql 46
      parse.get_span.get_type.should eql nil # ?
      parse.get_child_count.should eql 1

      child = parse.get_children[0]

      child.text.should eql "The death of the poet was kept from his poems."
      child.get_child_count.should eql 3
      child.get_head_index.should eql 5

      child.get_head.get_child_count.should eql 1
      child.get_type.should eql "S"

    end
  end

  context "the SimpleTokenizer is run" do
    it "tokenizes the text accurately" do
      
      OpenNLP.load
      
      sent = "The death of the poet was kept from his poems."
      tokenizer = OpenNLP::SimpleTokenizer.new
      tokens = tokenizer.tokenize(sent).to_a
      tokens.should eql %w[The death of the poet was kept from his poems .]
      
    end
  end

  context "the maximum entropy sentence detector, tokenizer, POS tagger " +
  "and NER finders are run with the default models for English" do

    it "should accurately detect tokens, sentences and named entities" do

      OpenNLP.load
      
      text = File.read('./spec/sample.txt').gsub!("\n", "")
      
      tokenizer   = OpenNLP::TokenizerME.new
      segmenter   = OpenNLP::SentenceDetectorME.new
      tagger      = OpenNLP::POSTaggerME.new
      ner_models  = ['person', 'time', 'money']

      ner_finders = ner_models.map do |model|
        OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
      end

      sentences = segmenter.sent_detect(text)
      all_entities, all_tags, all_sentences, all_tokens = [], [], [], []

      sentences.each do |sentence|

        tokens = tokenizer.tokenize(sentence)
        tags   = tagger.tag(tokens)
        
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

        all_tokens << tokens.to_a
        all_sentences << sentence
        all_tags << tags.to_a
        
      end

      all_tokens.should eql [["To", "describe", "2009", "as", "a", "stellar", "year", "for", "Petrofac", "(", "LON:PFC)", "would", "be", "a", "huge", "understatement", "."], ["The", "group", "finished", "the", "year", "with", "an", "order", "backlog", "twice", "the", "size", "than", "it", "had", "at", "the", "outset", "."], ["The", "group", "has", "since", "been", "awarded", "a", "US", "600", "million", "contract", "and", "spun", "off", "its", "North", "Sea", "assets", "."], ["The", "group", "’s", "recently", "released", "full", "year", "results", "show", "a", "jump", "in", "revenues", ",", "pre-tax", "profits", "and", "order", "backlog", "."], ["Whilst", "group", "revenue", "rose", "by", "10", "%", "from", "$", "3.3", "billion", "to", "$", "3.7", "billion", ",", "pre-tax", "profits", "rose", "by", "25", "%", "from", "$", "358", "million", "to", "$", "448", "million", ".All", "the", "more", "impressive", ",", "the", "group", "’s", "order", "backlog", "doubled", "to", "over", "$", "8", "billion", "paying", "no", "attention", "to", "the", "15", "%", "cut", "in", "capital", "expenditure", "witnessed", "across", "the", "oil", "and", "gas", "industry", "as", "whole", "in", "2009", ".Focussing", "in", "on", "which", "the", "underlying", "performances", "of", "the", "individual", "segments", ",", "the", "group", "cash", "cow", ",", "its", "Engineering", "and", "Construction", "division", ",", "saw", "operating", "profit", "rise", "33", "%", "over", "the", "year", "to", "$", "322", "million", ",", "thanks", "to", "US$", "6.3", "billion", "worth", "of", "new", "contract", "wins", "during", "the", "year", "which", "included", "a", "$", "100", "million", "contract", "with", "Turkmengaz", ",", "the", "Turkmenistan", "national", "energy", "company", "."], ["The", "division", "has", "picked", "up", "in", "2010", "where", "it", "left", "off", "in", "2009", "and", "has", "been", "awarded", "a", "contract", "worth", "more", "than", "US600", "million", "for", "a", "gas", "sweetening", "facilities", "project", "by", "Qatar", "Petroleum.Elsewhere", "the", "group", "’s", "Offshore", "Engineering", "&", "Operations", "division", "may", "have", "seen", "a", "pullback", "in", "revenue", "and", "earnings", "vis-a-vis", "2008", ",", "but", "it", "did", "secure", "a", "£75", "million", "contract", "with", "Apache", "to", "provideengineering", "and", "construction", "services", "for", "the", "Forties", "field", "in", "the", "UK", "North", "Sea", "."], ["And", "to", "underscore", "the", "fact", "that", "there", "is", "life", "beyond", "NOC’s", "for", "Petrofac", "(", "LON:PFC)", "the", "division", "was", "awarded", "a", "£100", "million", "5-year", "contract", "by", "BP", "(", "LON:BP.", ")", "to", "deliver", "integrated", "maintenance", "management", "support", "services", "for", "all", "of", "BP", "'s", "UK", "offshore", "assets", "and", "onshore", "Dimlington", "plant", "."], ["The", "laggard", "of", "the", "group", "was", "the", "Engineering", ",", "Training", "Services", "and", "Production", "Solutions", "division", "."], ["The", "business", "suffered", "as", "the", "oil", "price", "tailed", "off", "and", "the", "economic", "outlook", "deteriorated", "forcing", "a", "number", "ofmajor", "customers", "to", "postpone", "early", "stage", "engineering", "studies", "or", "re-phased", "work", "upon", "which", "the", "division", "depends", "."], ["Although", "the", "fall", "in", "activity", "was", "notable", ",", "the", "division’s", "operational", "performance", "in", "service", "operator", "role", "for", "production", "of", "Dubai", "'s", "offshore", "oil", "&", "gas", "proved", "a", "highlight.Energy", "Developments", "meanwhile", "saw", "the", "start", "of", "oil", "production", "from", "the", "West", "Don", "field", "during", "the", "first", "half", "of", "the", "year", "less", "than", "a", "year", "from", "Field", "Development", "Programme", "approval", "."], ["In", "addition", "output", "from", "Don", "Southwest", "field", "began", "in", "June", "."], ["Despite", "considerably", "lower", "oil", "prices", "in", "2009", "compared", "to", "the", "prior", "year", ",", "Energy", "Developments", "'", "revenue", "reached", "almost", "US$", "250", "million", "(", "significantly", "higher", "than", "the", "US$", "153", "million", "of", "2008", ")", "due", "not", "only", "to", "the", "‘Don", "fields", "effect", "’", "but", "also", "a", "full", "year", "'s", "contribution", "from", "the", "Chergui", "gas", "plant", ",", "which", "began", "exports", "in", "August", "2008.In", "order", "to", "maximize", "the", "earnings", "potential", "of", "the", "division’s", "North", "Sea", "assets", ",", "including", "the", "Don", "assets", ",", "the", "group", "has", "demerged", "them", "providing", "its", "shareholders", "with", "shares", "in", "a", "newly", "listed", "independent", "exploration", "and", "production", "company", "called", "EnQuest", "(", "LON:ENQ", ")", "."], ["EnQuest", "is", "a", "product", "of", "the", "Petrofac’s", "North", "Sea", "Assets", "with", "those", "off", "of", "Swedish", "explorer", "Lundin", "with", "both", "companies", "divesting", "for", "different", "reasons", "."], ["Upon", "listing", "(", "April", "6th", ")", ",", "Petrofac", "(", "LON:PFC)", "shareholders", "owned", "around", "45", "%", "of", "the", "new", "EnQuest", "entity", "with", "Lundin", "shareholders", "owning", "approximately", "55", "%", "."], ["It", "is", "important", "to", "note", "that", "post", "demerger", "the", "Energy", "Developments", "business", "unit", "is", "still", "a", "key", "constituent", "of", "Petrofac", "'s", "business", "portfolio", ",", "and", "will", "continue", "to", "hold", "significant", "assets", "Tunisia", ",", "Malaysia", ",", "Algeria", "and", "Kyrgyz", "Republic", "-", "sandwiched", "between", "Kazakhstan", "and", "China", "."]]

      all_sentences.should eql ["To describe 2009 as a stellar year for Petrofac (LON:PFC) would be a huge understatement.", "The group finished the year with an order backlog twice the size than it had at the outset.", "The group has since been awarded a US 600 million contract and spun off its North Sea assets.", "The group’s recently released full year results show a jump in revenues, pre-tax profits and order backlog.", "Whilst group revenue rose by 10% from $3.3 billion to $3.7 billion, pre-tax profits rose by 25% from $358 million to $448 million.All the more impressive, the group’s order backlog doubled to over $8 billion paying no attention to the 15% cut in capital expenditure witnessed across the oil and gas industry as whole in 2009.Focussing in on which the underlying performances of the individual segments, the group cash cow, its Engineering and Construction division, saw operating profit rise 33% over the year to $322 million, thanks to US$6.3 billion worth of new contract wins during the year which included a $100 million contract with Turkmengaz, the Turkmenistan national energy company.", "The division has picked up in 2010 where it left off in 2009 and has been awarded a contract worth more than US600 million for a gas sweetening facilities project by Qatar Petroleum.Elsewhere the group’s Offshore Engineering & Operations division may have seen a pullback in revenue and earnings vis-a-vis 2008, but it did secure a £75 million contract with Apache to provideengineering and construction services for the Forties field in the UK North Sea.", "And to underscore the fact that there is life beyond NOC’s for Petrofac (LON:PFC) the division was awarded a £100 million 5-year contract by BP (LON:BP.) to deliver integrated maintenance management support services for all of BP's UK offshore assets and onshore Dimlington plant.", "The laggard of the group was the Engineering, Training Services and Production Solutions division.", "The business suffered as the oil price tailed off and the economic outlook deteriorated forcing a number ofmajor customers to postpone early stage engineering studies or re-phased work upon which the division depends.", "Although the fall in activity was notable, the division’s operational performance in service operator role for production of Dubai's offshore oil & gas proved a highlight.Energy Developments meanwhile saw the start of oil production from the West Don field during the first half of the year less than a year from Field Development Programme approval.", "In addition output from Don Southwest field began in June.", "Despite considerably lower oil prices in 2009 compared to the prior year, Energy Developments' revenue reached almost US$250 million (significantly higher than the US$153 million of 2008) due not only to the ‘Don fields effect’ but also a full year's contribution from the Chergui gas plant, which began exports in August 2008.In order to maximize the earnings potential of the division’s North Sea assets, including the Don assets, the group has demerged them providing its shareholders with shares in a newly listed independent exploration and production company called EnQuest (LON:ENQ).", "EnQuest is a product of the Petrofac’s North Sea Assets with those off of Swedish explorer Lundin with both companies divesting for different reasons.", "Upon listing (April 6th), Petrofac (LON:PFC) shareholders owned around 45% of the new EnQuest entity with Lundin shareholders owning approximately 55%.", "It is important to note that post demerger the Energy Developments business unit is still a key constituent of Petrofac's business portfolio, and will continue to hold significant assets Tunisia, Malaysia, Algeria and Kyrgyz Republic - sandwiched between Kazakhstan and China."]

      all_entities.should eql [[["$", "3.3", "billion"], "money"], [["$", "3.7", "billion"], "money"], [["$", "358", "million", "to", "$", "448", "million"], "money"], [["$", "8", "billion"], "money"], [["$", "322", "million"], "money"], [["$", "100", "million"], "money"], [["Lundin"], "person"], [["Lundin"], "person"]]
      
      all_tags.should eql [["TO", "VB", "CD", "IN", "DT", "NN", "NN", "IN", "NNP", "-LRB-", "NNP", "MD", "VB", "DT", "JJ", "NN", "."], ["DT", "NN", "VBD", "DT", "NN", "IN", "DT", "NN", "NN", "RB", "DT", "NN", "IN", "PRP", "VBD", "IN", "DT", "NN", "."], ["DT", "NN", "VBZ", "RB", "VBN", "VBN", "DT", "PRP", "CD", "CD", "NN", "CC", "VBD", "RP", "PRP$", "NNP", "NNP", "NNS", "."], ["DT", "NN", "VBD", "RB", "VBN", "JJ", "NN", "NNS", "VBP", "DT", "NN", "IN", "NNS", ",", "JJ", "NNS", "CC", "NN", "NN", "."], ["NNP", "NN", "NN", "VBD", "IN", "CD", "NN", "IN", "$", "CD", "CD", "TO", "$", "CD", "CD", ",", "JJ", "NNS", "VBD", "IN", "CD", "NN", "IN", "$", "CD", "CD", "TO", "$", "CD", "CD", "PDT", "DT", "RBR", "JJ", ",", "DT", "NN", "VBZ", "NN", "NN", "VBD", "TO", "RP", "$", "CD", "CD", "VBG", "DT", "NN", "TO", "DT", "CD", "NN", "NN", "IN", "NN", "NN", "VBN", "IN", "DT", "NN", "CC", "NN", "NN", "IN", "JJ", "IN", "CD", "NN", "IN", "IN", "WDT", "DT", "JJ", "NNS", "IN", "DT", "JJ", "NNS", ",", "DT", "NN", "NN", "NN", ",", "PRP$", "NNP", "CC", "NNP", "NN", ",", "VBD", "NN", "NN", "VB", "CD", "NN", "IN", "DT", "NN", "TO", "$", "CD", "CD", ",", "NNS", "TO", "$", "CD", "CD", "NN", "IN", "JJ", "NN", "VBZ", "IN", "DT", "NN", "WDT", "VBD", "DT", "$", "CD", "CD", "NN", "IN", "NNP", ",", "DT", "NNP", "JJ", "NN", "NN", "."], ["DT", "NN", "VBZ", "VBN", "RP", "IN", "CD", "WRB", "PRP", "VBD", "RP", "IN", "CD", "CC", "VBZ", "VBN", "VBN", "DT", "NN", "NN", "JJR", "IN", "CD", "CD", "IN", "DT", "NN", "VBG", "NNS", "NN", "IN", "NNP", "NNP", "DT", "NN", "JJ", "NNP", "NNP", "CC", "NNP", "NN", "MD", "VB", "VBN", "DT", "NN", "IN", "NN", "CC", "NNS", "NN", "CD", ",", "CC", "PRP", "VBD", "VB", "DT", "CD", "CD", "NN", "IN", "NNP", "TO", "VB", "CC", "NN", "NNS", "IN", "DT", "NNP", "NN", "IN", "DT", "NNP", "NNP", "NNP", "."], ["CC", "TO", "VB", "DT", "NN", "IN", "EX", "VBZ", "NN", "IN", "NNP", "IN", "NNP", "-LRB-", "NNP", "DT", "NN", "VBD", "VBN", "DT", "CD", "CD", "JJ", "NN", "IN", "NNP", "-LRB-", "NNP", "-RRB-", "TO", "VB", "JJ", "NN", "NN", "NN", "NNS", "IN", "DT", "IN", "NNP", "POS", "NN", "JJ", "NNS", "CC", "RB", "NNP", "NN", "."], ["DT", "NN", "IN", "DT", "NN", "VBD", "DT", "NNP", ",", "NNP", "NNP", "CC", "NNP", "NNP", "NN", "."], ["DT", "NN", "VBD", "IN", "DT", "NN", "NN", "VBN", "RB", "CC", "DT", "JJ", "NN", "VBD", "VBG", "DT", "NN", "IN", "NNS", "TO", "VB", "JJ", "NN", "NN", "NNS", "CC", "JJ", "NN", "IN", "WDT", "DT", "NN", "VBZ", "."], ["IN", "DT", "NN", "IN", "NN", "VBD", "JJ", ",", "DT", "JJ", "JJ", "NN", "IN", "NN", "NN", "NN", "IN", "NN", "IN", "NNP", "POS", "JJ", "NN", "CC", "NN", "VBD", "DT", "RB", "NNPS", "RB", "VBD", "DT", "NN", "IN", "NN", "NN", "IN", "DT", "NNP", "NNP", "NN", "IN", "DT", "JJ", "NN", "IN", "DT", "NN", "RBR", "IN", "DT", "NN", "IN", "NNP", "NNP", "NNP", "NN", "."], ["IN", "NN", "NN", "IN", "NNP", "NNP", "NN", "VBD", "IN", "NNP", "."], ["IN", "RB", "JJR", "NN", "NNS", "IN", "CD", "VBN", "TO", "DT", "JJ", "NN", ",", "NNP", "NNPS", "POS", "NN", "VBD", "RB", "$", "CD", "CD", "-LRB-", "RB", "JJR", "IN", "DT", "$", "CD", "CD", "IN", "CD", "-RRB-", "RB", "RB", "RB", "TO", "DT", "JJ", "NNS", "NN", ",", "CC", "RB", "DT", "JJ", "NN", "POS", "NN", "IN", "DT", "NNP", "NN", "NN", ",", "WDT", "VBD", "NNS", "IN", "NNP", "IN", "NN", "TO", "VB", "DT", "NNS", "NN", "IN", "DT", "JJ", "NNP", "NNP", "NNS", ",", "VBG", "DT", "NNP", "NNS", ",", "DT", "NN", "VBZ", "VBN", "PRP", "VBG", "PRP$", "NNS", "IN", "NNS", "IN", "DT", "RB", "VBN", "JJ", "NN", "CC", "NN", "NN", "VBD", "NNP", "-LRB-", "NN", "-RRB-", "."], ["NNP", "VBZ", "DT", "NN", "IN", "DT", "NNP", "NNP", "NNP", "NNS", "IN", "DT", "IN", "IN", "JJ", "NN", "NN", "IN", "DT", "NNS", "VBG", "IN", "JJ", "NNS", "."], ["IN", "VBG", "-LRB-", "NNP", "NN", "-RRB-", ",", "NNP", "-LRB-", "NNP", "NNS", "VBD", "IN", "CD", "NN", "IN", "DT", "JJ", "NNP", "NN", "IN", "NNP", "NNS", "VBG", "RB", "CD", "NN", "."], ["PRP", "VBZ", "JJ", "TO", "VB", "IN", "NN", "NN", "DT", "NNP", "NNPS", "NN", "NN", "VBZ", "RB", "DT", "JJ", "NN", "IN", "NNP", "POS", "NN", "NN", ",", "CC", "MD", "VB", "TO", "VB", "JJ", "NNS", "NNP", ",", "NNP", ",", "NNP", "CC", "NNP", "NNP", ":", "VBD", "IN", "NNP", "CC", "NNP", "."]]
      
    end
  end

end
