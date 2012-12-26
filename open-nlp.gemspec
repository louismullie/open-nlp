$:.push File.expand_path('../lib', __FILE__)

require 'open-nlp'

Gem::Specification.new do |s|

  s.name        = 'open-nlp'
  s.version     = OpenNLP::VERSION
  s.authors     = ['Louis Mullie']
  s.email       = ['louis.mullie@gmail.com']
  s.homepage    = 'https://github.com/louismullie/open-nlp'
  s.summary     = %q{ Ruby bindings to the OpenNLP Java toolkit. }
  s.description = %q{ Ruby bindings to the OpenNLP tools, a Java machine learning toolkit for natural language processing (NLP). }
  
  # Add all files.
  s.files = Dir['bin/**/*'] + Dir['lib/**/*'] + Dir['spec/**/*'] +  ['README.md', 'LICENSE']
  
  # Runtime dependency.
  s.add_runtime_dependency 'bind-it', '~>0.2.5'
  
  # Development dependency.
  s.add_development_dependency 'rspec'
  
end