module Jekyll
  class MentionsTag < Liquid::Tag
    def initialize(tag, text, toks)
      super
      tokens = text.split
      @username = tokens.shift # || error?
      @service = tokens.shift || "twitter"
    end

    def render(context)
      base_url = case @service
        when "twitter"
          "https://twitter.com"
        when "github"
          "https://github.com"
      end
      "<a class=\"mentions-#{@service}\" href=\"#{base_url}/#{@username}\">@#{@username}</a>"
    end
  end
end

Liquid::Template.register_tag('mention', Jekyll::MentionsTag)
