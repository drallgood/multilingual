module Jekyll
  class Site
    def languages
      Octopress::Multilingual.languages
    end

    def posts_by_language(lang=nil)
      #Octopress::Multilingual.posts_by_language(lang)
      []
    end
  end

  class Document
    def lang
      if lang = data['lang']
        data['lang'] = site.config['lang'] if lang == 'default'
        data['lang'].downcase
      end
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_pages[data['translation_id']].reject {|p| p == self }
      end
    end

    def crosspost_languages
      data['lang_crosspost']
    end
  end

  class Page
    alias :permalink_orig :permalink

    def lang
      if lang = data['lang']
        data['lang'] = site.config['lang'] if lang == 'default'
        data['lang'].downcase
      end
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_pages[data['translation_id']].reject {|p| p == self }
      end
    end

    def crosspost_languages
      data['lang_crosspost']
    end
  end
end

