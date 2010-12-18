=begin rdoc
  This plugin is a collection of helper methods dealing with the processing and reading of Rails parameters.
  
  Usage:
  
    ExampleController < Application
      helper :params
      helper_method :flatten_params # to access a method inside the controller
    end
=end
module ParamsHelper
  
=begin rdoc
  Takes a nested hash and flattens it. This makes it especially useful for methods like link_to and url_for (which don't understand nested hashes).
  
  Examples:

    flatten_params({:a => {:b => 100}})
    => {"a[b]" => 100}    
=end
  def flatten_params(p, options = {})
    formatted = {}
    ignore = options[:ignore] || []
		
		p.each do |k1, v1|
			if v1.is_a?(Hash)
				v1.each do |k2, v2|
					unless v2.blank?
						formatted["#{k1}[#{k2}]"] = v2
					end
				end
			else
			  unless v1.blank?
					formatted[k1.to_s] = v1
				end
			end
		end
		
		ignore.each do |x|
		  formatted.delete(x)
	  end
	  
		return formatted
  end

=begin rdoc
  Builds a list of hidden fields from the supplied params. This will automatically flatten the params if necessary.

  Examples:
  
    build_hidden_fields({"a" => 100, "b" => {"c" => 200}})
    => <input type="hidden" value="100" name="a"/>
    => <input type="hidden" value="200" name="b[c]"/>
=end
  def build_hidden_fields(p, options = {})
    fields = []
    ignore = options[:ignore] || []

    p.each do |k1, v1|
      if v1.is_a?(Hash)
        v1.each do |k2, v2|
          if !v2.blank? && !ignore.include?(k2)
            fields << hidden_field_tag("#{k1}[#{k2}]", v2)
          end
        end
      elsif !v1.blank? && !ignore.include?(k1)
        fields << hidden_field_tag(k1, v1)
      end
    end
    
    return fields.join("\n")
  end

=begin rdoc
  Creates a text field that is automatically populated based on the parameters.
  
  Examples:
  
    params
    => {"a" => 100, "b" => {"c" => 200}}
  
    auto_text_field("b", "c")
    => <input type="text" value="200" name="b[c]"/>
  
    auto_text_field("a")
    => <input type="text" value="100" name="a"/>
=end
  def auto_text_field(object_name, field_name = nil, options = {})
    value = options[:value] || ""
    
    if field_name
      options[:id] ||= "#{object_name}_#{field_name}"

      if params[object_name] && params[object_name][field_name]
        value = params[object_name][field_name]
      else
        ivar = "@#{object_name}"
        if instance_variable_defined?(ivar)
          ivar = instance_variable_get(ivar)
          value = ivar.__send__(field_name)
        end
      end
    
      return text_field_tag("#{object_name}[#{field_name}]", value, options)
    else
      options[:id] ||= object_name

      if params[object_name]
        value = params[object_name]
      end
      
      return text_field_tag(object_name, value, options)
    end
  end

=begin rdoc
  Creates a hidden field that is automatically populated based on the parameters. See auto_text_field for details.
=end
  def auto_hidden_field(object_name, field_name = nil, options = {})
    value = options[:value] || ""
    
    if field_name
      options[:id] ||= "#{object_name}_#{field_name}"

      if params[object_name] && params[object_name][field_name]
        value = params[object_name][field_name]
      else
        ivar = "@#{object_name}"
        if instance_variable_defined?(ivar)
          ivar = instance_variable_get(ivar)
          value = ivar.__send__(field_name)
        end
      end
    
      return hidden_field_tag("#{object_name}[#{field_name}]", value, options)
    else
      options[:id] ||= object_name

      if params[object_name]
        value = params[object_name]
      end
      
      return hidden_field_tag(object_name, value, options)
    end
  end

=begin rdoc
  Creates a check box that is automatically populated based on the parameters. See auto_text_field for details.
=end
  def auto_check_box(object_name, field_name = nil, options = {})
    value = ""
    check_box_value = options[:value] || "1"
        
    if field_name
      options[:id] ||= "#{object_name}_#{field_name}"
      
      if params[object_name] && params[object_name][field_name]
        value = params[object_name][field_name]
      else
        ivar = "@#{object_name}"
        if instance_variable_defined?(ivar)
          ivar = instance_variable_get(ivar)
          value = ivar.__send__(field_name)
        end
      end
      
      return check_box_tag("#{object_name}[#{field_name}]", check_box_value, value == check_box_value, options)
    else
      options[:id] ||= object_name
      
      if params[object_name]
        value = params[object_name]
      end
      
      return check_box_tag(object_name, check_box_value, value == check_box_value, options)
    end
  end

=begin rdoc
  Creates a select menu that is automatically populated based on the parameters. See auto_text_field for details.
=end
  def auto_select(object_name, field_name, choices, options = {})
    value = options[:value] || ""
    
    if field_name
      options[:id] ||= "#{object_name}_#{field_name}"
      
      if params[object_name] && params[object_name][field_name]
        value = params[object_name][field_name]
      else
        ivar = "@#{object_name}"
        if instance_variable_defined?(ivar)
          ivar = instance_variable_get(ivar)
          value = ivar.__send__(field_name)
        end
      end
            
      return select_tag("#{object_name}[#{field_name}]", options_for_select(choices, value), options)
    else
      options[:id] ||= object_name

      if params[object_name]
        value = params[object_name][field_name]
      end
      
      return select_tag(object_name, options_for_select(choices, value), options)
    end
  end
end
