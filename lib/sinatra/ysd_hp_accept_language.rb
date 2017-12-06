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

    #
    # Format an url with the current language
    #
    def format_url_with_language(the_url)

      if translation_locale = locale_to_translate_into
        "/#{translation_locale}#{the_url}"
      else
        the_url
      end
    end

    #
    # Get the locate to which the information should be translated into or nil if it is not necessary
    #
    def locale_to_translate_into
      multilanguage_site = settings.multilanguage_site
      default_language = settings.default_language
      if multilanguage_site and session[:locale] != default_language
        session[:locale]
      else
        nil
      end
    end

    #
    # Setup the session[:locale]
    #
    def setup_session_locale_from_params
      default_language = settings.default_language
      session[:locale] = params[:lang] if params[:lang] and params[:lang] != default_language
    end
    
  end
  
  helpers HttpAcceptLanguage
  
end