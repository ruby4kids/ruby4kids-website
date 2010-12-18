# DateSelectorHelper allows you to popup a calendar screen to select a date value for your date selector field.
#	<%=date_selector :object, :method, {:value => params[:form][:method], :size => 15} %>
module DateSelectorHelper

    def date_selector(model, method, params={})
      result = text_field(model,method,params)
      result << "<img  id=\"trigger_#{method}\" onmouseout=\"this.style.background=''\" onmouseover=\"this.style.background='blue';\""
      result << " title=\"Date selector\" style=\"cursor: pointer;\" src=\"#{image_path('img.gif')}\" />"
      result << "<script type=\"text/javascript\"> \n"
      result << "Calendar.setup({inputField: \"#{model.to_s}_#{method.to_s}\",\n"
      result << " ifFormat    : \"%Y-%m-%d\",    // the date format \n"
      result << " button      : \"trigger_#{method.to_s}\"       // ID of the button\n"
      result << "});\n"
      result << "</script>"
    end

end
