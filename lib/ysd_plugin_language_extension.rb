require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener

#
# Huasi Profile Extension
#
module Huasi

  class PluginLanguageExtension < Plugins::ViewListener

    # ========= Installation =================

    #
    # Install the plugin
    #
    def install(context={})

      SystemConfiguration::Variable.first_or_create(
          {:name => 'language.multilanguage_site'},
          {:value => 'false',
           :description => 'langaugesmtp settings : from address',
           :module => :language})

      SystemConfiguration::Variable.first_or_create(
          {:name => 'language.default_local'},
          {:value => 'es',
           :description => 'default site language',
           :module => :language})

      SystemConfiguration::Variable.first_or_create(
          {:name => 'language.available_locales'},
          {:value => 'es',
           :description => 'available site languages (comma separated)',
           :module => :language})

      SystemConfiguration::Variable.first_or_create(
          {:name => 'language.ignore_http_accept_language'},
          {:value => 'true',
           :description => 'ignore HTTP Accept-Language',
           :module => :language})

    end

  end
end