module Sinatra

  module HttpAcceptLanguage
    
    # Process Accepted-Languages header to extract the browser languages
    #
    # returns an array with the accepted languages
    def process_accepted_language_header (accepted_language)
   
      languages_codes = accepted_language.scan(/(\w+)(-\w+)?(;q=\d+(\.\d+)?)?/).collect do 
        |element| element[0]
      end
   
      languages_codes.uniq # Return an array without repeated elements
     
    end  

    def format_url_with_language(the_url)
      if settings.multilanguage_site and session[:locale] != settings.default_locale
        "/#{session[:locale]}#{the_url}"
      else
        the_url
      end
    end
    
  end
  
  helpers HttpAcceptLanguage
  
end