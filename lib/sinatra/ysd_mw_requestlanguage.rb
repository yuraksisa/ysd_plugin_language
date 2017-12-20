require 'sinatra/base'
require 'sinatra/ysd_hp_accept_language'

module Sinatra

  module RequestLanguageHelper

    # 
    # Get the current path with the language prefix
    #
    def current_path_with_language(language)
    
      # Extract the language from the request.path 
      subpath_info = ''
      unless request.path.empty?
        subpath_info = request.path.sub(Middleware::RequestLanguageProcessor.settings.regexp_prefix,'') ||''
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
  class RequestLanguageProcessor < Sinatra::Base

     helpers Sinatra::HttpAcceptLanguage
          
     # Configuration     
     configure do

       set :multilanguage_site, false                      # Multilanguage site
       set :ignore_http_accept_language, true              # Ignore the HTTP_ACCEPT_LANGUAGE header in multi languages site to keep the default language 
       set :default_locale, "es"                           # Site default language    
       set :regexp_prefix, /^\/(ca|en|fr|it|de)\/?$/          # It defines the regular expression that matches the site languages    
       set :site_locales, ["ca","en","es","fr","it","de"]  # It defines an array with the site languages

     end

     #
     # Retrieves the language from the HTTP_ACCEPT_LANGUAGE or uses the default_locale 
     # configured for the Site
     #
     before :method => :get do

       # ---- Pre process

       unless settings.multilanguage_site 
         pass
       end

       if request.path_info.start_with?('/change-language')
         pass
       end

       # ---- Process

       # 1. Extract the language from the request (first element in the request.path_info)
       request_language = request.path_info.scan(/\w+/).first
       request_language_params = params[:lang] if params[:lang] and
                                                  request_language != settings.default_locale and !(settings.site_locales.include?(request_language)) and
                                                  settings.site_locales.include?(params[:lang]) and params[:lang] != settings.default_locale

       #p "request_language_params: #{request_language_params} path: #{request.path_info} -- #{params[:lang]}"

       # 2.a If the language is included in the request (and it's not the default language)
       #
       # => Process the URL without language preffix
       #
       # NOTE: The site default language is not included in the request
       #      
       if !request_language.nil? and !request_language.empty? and
          request_language != settings.default_locale and 
          settings.site_locales.include?(request_language)
         
         session[:request_locale] = request_language  
         path_without_language = request.path_info.gsub(/^\/#{request_language}/,'')
         status, header, body = call! env.merge("PATH_INFO" => path_without_language) 

       elsif !request_language_params.nil?
         session[:locale] = session[:request_locale] = request_language_params
         Thread.current[:model_locale] = session[:locale]
       else
         # 2.b If the language is not included in the request 
         #
         # => Set up the session[:locale] -> session[:request_locale] || settings.default_locale
         #
         session[:locale] = session[:request_locale] || settings.default_locale
         Thread.current[:model_locale] = session[:locale]
       end      
  
     end
  
     after :method => :get do

       session.delete(:request_locale)

     end
  
  end

end