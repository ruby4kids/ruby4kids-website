class <%= singular_name.classify %> < ActiveRecord::Base
protected
  def self.join_table_mappings
    return {
      "<%= singular_name %>" => {
        "model_name" => <%= singular_name.classify %>,
        "table_name" => "<%= singular_name.pluralize %>",
        "join_relationships" => ""
      }
    }
  end
end
