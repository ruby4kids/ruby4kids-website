module LayoutHelper

  attr_accessor :raw_title, :body_class, :active_section
  attr_writer :title

  def layout_options(options = {})
    return if options.blank?
    opts = options.clone
    opts.keys.each do |key|
      setter = "#{key}=".intern
      if self.respond_to?(setter)
        self.send(setter, opts.delete(key))
        next
      else
        raise "No layout option found for #{key}"
      end
    end
    nil
  end

  def title
    sep = ' - '
    controller_title = [controller.controller_name.titleize, controller.action_name.titleize].join(sep)
    view_title = @title ? (@title.is_a?(Array) ? @title.join(sep) : @title) : controller_title
    raw(raw_title ? raw_title : [t(:application), view_title].join(sep))
  end

  def active_section_class(section)
    'active' if section == active_section
  end

end
