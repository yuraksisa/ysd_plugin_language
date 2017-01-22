module Sinatra

  module LanguageExtract

    def self.registered(app)

     # Configuration     
     app.set :regexp_locales, /\/(ca|en|es|fr)$/   # It defines the regular expression that matches the site languages    
     app.set :site_locales, ["ca","en","es","fr"]    # It defines an array with the site languages
     app.set :default_locale, "es"              # It defines the site default language    

     app.post '/change-language/?' do
       
       language = params[:language]
       url = params[:url]

       p "Change language #{params[:url]}"

       session[:locale] = language

       suffixes = %w(/es/ /en/ /ca/ /fr/)

       if url 
         if url.start_with?(*suffixes)
           redirection_path = "/#{language}"
           redirection_path << url[4,url.length]
           p "REDIRECT #{redirection_path}"
           redirect redirection_path, 301
         else
           if url == '/'
             p "REDIRECT /#{language}"
             redirect "/#{language}", 301
           end
         end
       else
         p "REDICT #{url} ***** /#{language}"
         redirect "/#{language}"
       end

     end


    end

  end
end