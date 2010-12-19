module ActionView
  module Helpers

    # The type attribute is unnecessary in HTML5.
    def javascript_src_tag(source, options)
      content_tag('script', '', { 'src' => path_to_javascript(source) }.merge(options))
    end

    # The type attribute is unnecessary in HTML5.
    def stylesheet_tag(source, options)
      tag('link', { 'rel' => 'stylesheet', 'media' => 'screen', 'href' => html_escape(path_to_stylesheet(source)) }.merge(options), false, false)
    end

  end
end
