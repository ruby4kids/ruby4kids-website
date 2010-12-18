require 'fileutils'

app_dir         = File.expand_path( "." )
plugins_dir     = File.join( app_dir, "vendor/plugins")
app_public_dir  = File.join( app_dir, "public")
app_public_javascripts_dir  = File.join( app_public_dir, "javascripts")
app_public_stylesheets_dir  = File.join( app_public_dir, "stylesheets")
app_public_images_dir  = File.join( app_public_dir, "images")
date_selector_plugin_dir  = File.join( plugins_dir, 'date_selector_helper')
date_selector_plugin_javascripts_dir  = File.join( date_selector_plugin_dir, "javascripts")
date_selector_plugin_stylesheets_dir  = File.join( date_selector_plugin_dir, "stylesheets")
date_selector_plugin_images_dir  = File.join( date_selector_plugin_dir, "images")


puts "- Copying date_selector_helper javascripts to #{app_public_javascripts_dir} directory..."
FileUtils.cp_r File.join( date_selector_plugin_javascripts_dir, '.' ), app_public_javascripts_dir

puts "- Copying date_selector_helper stylesheets to #{app_public_stylesheets_dir} directory..."
FileUtils.cp_r File.join( date_selector_plugin_stylesheets_dir, '.' ), app_public_stylesheets_dir  

puts "- Copying date_selector_helper image to #{app_public_images_dir} directory..."
FileUtils.cp_r File.join( date_selector_plugin_images_dir, '.' ), app_public_images_dir 

application_layout=File.join( app_dir, "app/views/layouts/application.rhtml")
application_layout_bk=File.join( app_dir, "app/views/layouts/application_old.rhtml")
FileUtils.mv application_layout, application_layout_bk
new_layout=File.new(application_layout,"w")
old_layout=File.open(application_layout_bk,"r")
while(line=old_layout.gets)
  	new_layout<<line
    if line.include?("</title>")
      new_layout<<" <%= stylesheet_link_tag(\"calendar-blue\") %>\n"
      new_layout<<" <%= javascript_include_tag(\"calendar\") %>\n"
      new_layout<<" <%= javascript_include_tag(\"lang/calendar-en\") %>\n"
      new_layout<<" <%= javascript_include_tag(\"calendar-setup\") %>\n"
    end
end 
new_layout.close
old_layout.close
FileUtils.rm application_layout_bk

puts "Date_Selector_Helper was successfully installed !!"                                             

