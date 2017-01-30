Gem::Specification.new do |s|
  s.name    = "ysd_plugin_language"
  s.version = "0.1.9"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2011-10-25"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb'] + Dir['views/**/*.erb'] 
  s.description = "Sinatra middleware that manages errors and exceptions using templates configured in the views directory"
  s.summary = "Error management plugin"
  
  s.add_runtime_dependency "ysd_yito_core"  # Page serving
  
end