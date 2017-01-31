module Sinatra

  #
  # Add route to an sinatra application to change the language for an URL
  #
  module LanguageExtract

    def self.registered(app)

     # LANGUAGE Setup Configuration
     app.set :multilanguage_site, false                       # Multilanguage site
     app.set :default_locale, "es"                            # Default site language  
     app.set :site_locales, ["ca","en","es","fr","it","de"]   # Site languages
     app.set :regexp_prefix, /^\/(ca|en|fr|it|de)\/?/          # RegExp language prefix

     app.post '/change-language/?' do
       
       if settings.multilanguage_site

         language = params[:language] # The selected language
         url = params[:url]           # The current URL
         url_language = url.scan(/\w+/).first 

         #p "Change Language. language: #{language} url: #{url} url_language: #{url_language}"

         # Build the url without the language
         url_without_language = url 
         # The URL contains language
         if !url_language.nil? and !url_language.empty? and 
            url_language != settings.default_locale and 
            settings.site_locales.include?(url_language)
            #p "Change Language. URL contains language #{url}"
            url_without_language = url.gsub(/^\/#{url_language}/,'')
         end

         # Build the redirection path
         redirection_path = if language == settings.default_locale 
                              url_without_language
                            else
                              if url_without_language != '/'
                                "/#{language}#{url_without_language}"
                              else
                                "/#{language}"
                              end
                            end

         #p "Change Language. Redirection path: #{redirection_path} URL without language: #{url_without_language}"
         redirect redirection_path, 301

       else  
         status 404 # It does not make change for a non multilanguage site
       end

     end


    end

  end
end