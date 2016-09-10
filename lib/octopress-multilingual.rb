require 'liquid'

require "octopress-multilingual/version"
require "octopress-multilingual/set_lang_tag"
require "octopress-multilingual/translation_tag"
require "octopress-multilingual/filters"
require "octopress-multilingual/hooks"
require "octopress-multilingual/jekyll"
require "octopress-multilingual/command"
require "octopress-debugger"

module Octopress
  module Multilingual
    extend self
    attr_accessor :site

    def main_language
      @lang ||= begin
        if lang = site.config['lang']
          lang.downcase
        end
      end
    end

    def site
      @site ||= Octopress.site
    end

    def language_name(name=nil)
      language_names[name] || name
    end

    def lang_dict
      @lang_dict ||= begin
        data = {}
        site.languages.each do |lang|
          data[lang] = site.data["lang_#{lang}"]
        end
        data
      end
    end

    def language_names
      @language_names ||= begin
        config = SafeYAML.load_file(File.expand_path('../../language_key.yml', __FILE__))
        if lang_config = site.config['language_names']
          config.merge!(lang_config)
        end
        config
      end
    end

    def translated_posts
      @translated_posts ||= begin
        filter = lambda {|p| p.data['translation_id']}
        site.posts.reverse.select(&filter).group_by(&filter)
      end
    end

    def translated_pages
      @translated_pages ||= begin
        filter = lambda {|p| p.data['translation_id']}
        site.pages.select(&filter).group_by(&filter)
      end
    end

    def languages
      @languages ||= begin
        languages = Array.new
        site.collections.each do |collection_name, collection|
          languages.concat(collection.docs.select(&:lang).group_by(&:lang).keys)
        end
        (languages.unshift(main_language)).uniq
      end
    end

    def page_payload(lang, payload={})
      if lang
        payload['site'] ||= {}
        payload['lang'] = lang_dict[lang]

        if defined?(Octopress::Ink) && site.config['lang']
          payload.merge!(Octopress::Ink.payload(lang))
        end
      end

      payload
    end
    
    def site_payload(payload)
      if main_language
        payload['site'].merge!({
          'languages'              => languages
        })
        payload['lang'] = lang_dict[main_language]
      end
    end
  end
end


if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Octopress Multilingual",
    gem:         "octopress-multilingual",
    version:     Octopress::Multilingual::VERSION,
    description: "Add multilingual features to your Jekyll site",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "..")),
    source_url:  "https://github.com/octopress/multilingual"
  })
end
