require 'sinatra/base'
require 'sinatra/ysd_hp_accept_language'

module Sinatra

  module RequestLanguageHelper

    # 
    # Get the current path with the language prefix
    #
    def current_path_with_language(language)
    
      # Extract the language from the request.path (before I used request.path_info)
      subpath_info = ''
      unless request.path.empty?
        subpath_info = request.path.sub(Middleware::RequestLanguage.settings.regexp_locales,'') ||''
      end
      subpath_info << '/' if subpath_info.reverse.index('/') != 0  
      subpath_info.gsub!(/\/+/,'/')      
      
      subpath_info + language
      
      
    end
 
  end

end

module Middleware

  # ------------------------------------
  # Multilanguage
  # ------------------------------------
  # 
  # Sets the session[:locale] based on the HTTP_ACCEPT_LANGUAGE, the URI path or the default configuration  
  #
  # - If the request path starts by a valid locale (example: /en or /es), configure it as the request language 
  # - If not and the header HTTP_ACCEPT_LANGUAGE is present, the header is used
  # - If not, it uses settings.site_locales
  #
  # First, it tries to retrieve the language from the header HTTP_ACCEPT_LANGUAGE
  #
  #
  #
  class RequestLanguage < Sinatra::Base

     helpers Sinatra::HttpAcceptLanguage
          
     # Configuration     
     configure do
       set :regexp_locales, /\/(ca|en|es)$/   # It defines the regular expression that matches the site languages    
       set :site_locales, ["ca","en","es"]    # It defines an array with the site languages
       set :default_locale, "es"              # It defines the site default language    
     end

     #
     # Retrieves the language from the HTTP_ACCEPT_LANGUAGE or uses the default language configured for the Site
     #
     before do

       request_language = request.path_info.scan(/\w+/).last
              
       if (not request_language.nil?) && (settings.site_locales.include? request_language)
         puts "language in the request : #{request_language}"
         session[:locale] = request_language   
       else
         unless session[:locale]
           puts "does not exist locale : #{request.env['HTTP_ACCEPT_LANGUAGE'].nil?}"
           if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
             session[:locale] = settings.default_locale
           else
             session[:locale] = (process_accepted_language_header(request.env['HTTP_ACCEPT_LANGUAGE']) & settings.site_locales).first || settings.default_locale
           end
         end
       end
       
       session[:locale] = settings.default_locale if not settings.site_locales.include?(session[:locale])
       
       # Take the language away from the request
       
       env['PATH_INFO'] = env['PATH_INFO'].sub(settings.regexp_locales,'')
  
     end
  
  
  end


end