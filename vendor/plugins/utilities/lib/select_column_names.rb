module ActiveRecord
  class Base
    class << self # Class methods
      def select_column_names
        model_table_name=''
        select_columns=''

        column_names_array = self.column_names
        model_table_name = self.table_name
        column_names_array.each_index do |column_index|
          if column_names_array.size == column_index+1
            select_columns += model_table_name+"."+column_names_array[column_index]
          else
            select_columns += model_table_name+"."+column_names_array[column_index]+", "
          end
        end 
        return select_columns
      end
    end
  end
end