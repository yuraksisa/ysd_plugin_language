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
        subpath_info = request.path.sub(Middleware::RequestLanguageProcessor.settings.regexp_locales,'') ||''
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
       set :regexp_locales, /\/(ca|en|es|fr)$/   # It defines the regular expression that matches the site languages    
       set :site_locales, ["ca","en","es","fr"]    # It defines an array with the site languages
       set :default_locale, "es"              # It defines the site default language    
     end

     #
     # Retrieves the language from the HTTP_ACCEPT_LANGUAGE or uses the default language configured for the Site
     #
     before :method => :get do

       #p "BEFORE GET #{request.path}"

       if request.path_info.start_with?('/change-language')
         pass
       end

       #p "Language processor #{request.path_info} #{request.query_string}"

       #request_language = request.path_info.scan(/\w+/).last
       request_language = request.path_info.scan(/\w+/).first

       #p "*** request.path_info:    #{request.path_info}"
       #p "request.query_string: #{request.query_string}"
       #p "first parameter:     #{request_language}"

        
       # Language in request       
       if (not request_language.nil?) and (settings.site_locales.include? request_language)
         #p "language in request: #{request_language} path: #{request.path_info}"
         session[:locale] = request_language  
         #path_without_language = request.path_info[0, request.path_info.length-3]
         path_without_language = request.path_info.gsub "/#{session[:locale]}",''
         #p "language in request path without language: #{path_without_language}"
         status, header, body = call! env.merge("PATH_INFO" => path_without_language) 
       # Not language in request
       else
         #p "not language in request. path: #{request.path_info} session[:locale] : #{session[:locale]} HTTP ACCEPT LANGUAGE : #{request.env['HTTP_ACCEPT_LANGUAGE']}"
         #puts "Language processor. Language in session: #{session[:locale]}"
         unless session[:locale]
           if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
             session[:locale] = settings.default_locale
           else
             session[:locale] = (process_accepted_language_header(request.env['HTTP_ACCEPT_LANGUAGE']) & settings.site_locales).first || settings.default_locale
           end
         end
         session[:locale] = settings.default_locale if not settings.site_locales.include?(session[:locale])
         #p "not language in request. final session[:locale] = #{session[:locale]}"

         preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_language', {:app => self})

         if (not request.path_info.start_with?(*preffixes)) and 
            (not request.path_info.match("\\.")) # =~ /^[^.]*$/)
           redirection_path = "/#{session[:locale]}"
           redirection_path << request.path_info
           redirection_path << "?#{request.query_string}" unless request.query_string.empty?
           #p "Serving redirected resource (locale) redirection_path : #{redirection_path}"
           redirect redirection_path, 301
         else
           #puts "Serving resource not locale #{request.path_info}"
         end

       end      
  
     end
  
  
  end

end