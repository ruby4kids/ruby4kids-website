class WebPage < ActiveRecord::Base
  
  belongs_to :page_layout
  belongs_to :website
  
  def to_html
    html = self.page_layout.content
    html = html.gsub("[[CONTENT]]", self.content)
    
    #replace [[filename_here.flv]] with the javascript and swf code below
    html = html.gsub(/\[\[(\w+\.flv)\]\]/) do |string| 
      attachment = Attachment.find_by_filename($1)
      video_html = ""
      if attachment
        video_html << "<div id=\"player\"></div>\n"
        video_html << "<script type=\"text/javascript\">\n"
        video_html << "var so = new SWFObject(\"/ruby4kids/player.swf\", \"video\", \"328\", \"285\", \"9\", \"#FFFFFF\");\n"
        video_html << "so.addParam(\"allowfullscreen\",\"true\");\n"
        video_html << "so.addVariable(\"file\", \"/ruby4kids/public/stream/#{attachment.filename}\");\n"
        video_html << "so.write(\"player\");\n"
        video_html << "</script>\n"
      end
      video_html
    end
    html
  end
  
  def self.default(website)
    self.find_or_create_by_name("Home")
  end
  
protected
  def self.join_table_mappings
    return {
      "web_page" => {
        "model_name" => WebPage,
        "table_name" => "web_pages",
        "join_relationships" => ""
      }
    }
  end
end
