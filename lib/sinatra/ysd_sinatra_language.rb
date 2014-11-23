module Sinatra

  module LanguageExtract

    def self.registered(app)

     # Configuration     
     app.set :regexp_locales, /\/(ca|en|es)$/   # It defines the regular expression that matches the site languages    
     app.set :site_locales, ["ca","en","es"]    # It defines an array with the site languages
     app.set :default_locale, "es"              # It defines the site default language    

     app.post '/change-language/?' do
       
       language = params[:language]
       url = params[:url]

       p "Change language #{params[:url]}"

       session[:locale] = language

       suffixes = %w(/es /en /ca)
       if url 
         if url.end_with?(*suffixes)
           p "Redirect #{url} ** #{url[0, url.length-3]}/#{language}"
           redirect "#{url[0, url.length-3]}/#{language}"
         else
           if url.end_with?('/')
             p "Redirect #{url} *** #{url}#{language}"
             redirect "#{url}#{language}"
           else 
             p "Redirect #{url} **** #{url}/#{language}"
             redirect "#{url}/#{language}"
           end
         end
       else
         p "Redirect #{url} ***** /#{language}"
         redirect "/#{language}"
       end

     end


    end

  end
end