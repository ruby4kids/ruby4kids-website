class PublicController < ApplicationController
  
  skip_before_filter :check_authentication, :check_rights, :set_current_person_id
  
  caches_page :picture
  
  def web_page
    @web_page = WebPage.find(params[:id])
    render :text => @web_page.to_html
  end
  
  def index
    redirect_to :action => :web_page, :id => WebPage.default(Website.default)
  end
  
  def picture
    picture = Picture.find(params[:id])
    send_data(picture.db_file.data, :type => picture.content_type,
                      :filename => picture.filename,
                      :size => picture.size)
  end
  
  def stream_f
    attachment = Attachment.find_by_filename(params[:id]+'.flv')
    filename_prefix = "/u/apps/ruby4kids/shared/attachments"
    filename = filename_prefix + attachment.public_filename.gsub(/^\/attachments/,"")
    send_file(filename, :filename => attachment.filename, :type => 'video/x-flv', :disposition => 'inline')
  end
  
  def stream
    attachment = Attachment.find_by_filename(params[:id]+'.flv') rescue nil
    if attachment
      filename_prefix = "/u/apps/ruby4kids/shared/attachments"
      filename = filename_prefix + attachment.public_filename.gsub(/^\/attachments/,"")
      response.headers['Content-Type'] = 'video/x-flv'
      response.headers['Content-Disposition'] = "inline; filename=\"#{File.basename(filename)}\""
      response.headers['X-Sendfile'] = filename
      render :nothing => true
    else
      render :nothing => true, :status => 404
    end
  end
  
  def download
    attachment = Attachment.find(params[:id])
    if attachment
      filename_prefix = "/u/apps/ruby4kids/shared/attachments"
      filename = filename_prefix + attachment.public_filename.gsub(/^\/attachments/,"")
      response.headers['Content-Type'] = 'application/force-download'
      response.headers['Content-Disposition'] = "attachment; filename=\"#{File.basename(filename)}\""
      response.headers['X-Sendfile'] = filename
      render :nothing => true
    else
      render :text => "File not found."
    end
  end
  
end
