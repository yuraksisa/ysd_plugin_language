require 'ysd-plugins' unless defined?Plugins::Plugin

Plugins::SinatraAppPlugin.register :request_language do

   name=        'request_language'
   author=      'yurak sisa'
   description= 'HTTP request language management'
   version=     '0.1'
   hooker       Huasi::PluginLanguageExtension
   sinatra_helper Sinatra::HttpAcceptLanguage   
  
end