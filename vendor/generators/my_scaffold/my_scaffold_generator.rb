class MyScaffoldGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :model
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = args.shift
    @controller_name ||= @name
    @controller_name = @controller_name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    @model = model_instance.class
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest", "#{controller_class_name}Helper"


      # Controller, helper, views, and test directories.
      m.directory File.join("app/models", class_path)
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('app/views/layouts', controller_class_path)
      m.directory File.join('app/views', 'shared')
      m.directory File.join('test/functional', controller_class_path)
      
      # Scaffolded views.
      scaffold_views.each do |action|
        m.template("view_#{action}.rhtml", File.join('app/views', controller_class_path, controller_file_name, "#{action}.rhtml"))
      end

      # Controller class, functional test, helper, and views.
      m.template 'model.rb', File.join('app/models', class_path, "#{singular_name}.rb")
      m.template 'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      m.template 'functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb")
      m.template 'unit_test.rb', File.join('test/unit', class_path, "#{file_name}_test.rb")
      m.template 'helper.rb', File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb")
      m.template '_page_selector.rhtml', File.join('app/views/shared/', "_page_selector.rhtml")
      m.template '_form.rhtml', File.join('app/views', controller_class_path, controller_file_name, "_form.rhtml")
      m.template '_query_form.rhtml', File.join('app/views', controller_class_path, controller_file_name, "_query_form.rhtml")

      # Unscaffolded views.
      unscaffolded_actions.each do |action|
        path = File.join('app/views', controller_class_path, controller_file_name, "#{action}.rhtml")
        m.template "controller:view.rhtml", path, :assigns => { :action => action, :path => path}
      end
    end
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} scaffold ModelName [ControllerName] [action, ...]"
  end

  def scaffold_views
    %w(list show new edit find)
  end

  def scaffold_actions
    scaffold_views + %w(index create update destroy)
  end
  
  def model_name 
    class_name.demodulize
  end

  def unscaffolded_actions
    args - scaffold_actions
  end

  def suffix
    "_#{singular_name}" if options[:suffix]
  end

  def create_sandbox
    sandbox = ScaffoldingSandbox.new
    sandbox.singular_name = singular_name
    begin
      sandbox.model_instance = model_instance
      sandbox.instance_variable_set("@#{singular_name}", sandbox.model_instance)
    rescue ActiveRecord::StatementInvalid => e
      logger.error "Before updating scaffolding from new DB schema, try creating a table for your model (#{class_name})"
      raise SystemExit
    end
    sandbox.suffix = suffix
    sandbox
  end
  
  def model_instance
    base = class_nesting.split('::').inject(Object) do |base, nested|
      break base.const_get(nested) if base.const_defined?(nested)
      base.const_set(nested, Module.new)
    end
    unless base.const_defined?(@class_name_without_nesting)
      base.const_set(@class_name_without_nesting, Class.new(ActiveRecord::Base))
    end
    class_name.constantize.new
  end
end
