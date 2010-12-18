#Build the hidden query with the params hash
def hidden_fields_build(params, table_array)
	hidden_fields = ''
	if table_array.any?
		table_array.uniq.each do |each_table_in_param|
			params[each_table_in_param].each do |k, v| 
				hidden_fields += %Q{<input id="#{each_table_in_param}_#{k.to_s}" type="hidden" name="#{each_table_in_param}[#{k.to_s}]" value="#{v}">\n}
			end
		end
	end
	return hidden_fields
end

module SearchAndPaginate
	# The following two methods separate the logic between condition generation and paginator generation
	# from the original search_and_paginate method. This was necessary because the Dashboard views don't
	# need pagination.
	# -- ayi
	def generate_conditions(params, model, options = {})
		conditions_and_joins = search_get_conditions(params, model)
    conditions = conditions_and_joins[0] || []
    condition_params = conditions_and_joins[1] || []
    joins = conditions_and_joins[2] || []
    hidden_fields = hidden_fields_build(params, conditions_and_joins[3] || [])

		if options[:extra_conditions]
			conditions += options[:extra_conditions]
		end

		if options[:extra_params]
			condition_params += options[:extra_params]
		end
		
		if options[:extra_joins]
      joins += options[:extra_joins]
    end
    
		if conditions.any?
		  conditions_with_params = [conditions.join(" AND "), *condition_params]
	  else
	    conditions_with_params = nil
    end
    
    joins = joins.join(" ")
		
		return {:conditions => conditions_with_params, :joins => joins, :hidden_fields => hidden_fields}
	end

	def search_and_paginate(params, model, options = {})
	  params.each_value do |v|
  	  if v.is_a?(Hash)
  	    v.delete_if {|kk, vv| vv.blank?}
      end
    end
    
    params.delete_if {|k, v| v.blank?}
  	
	  options[:order] ||= "id DESC"
		condition_hash = generate_conditions(params, model, options)
		select_fields = options[:select] || model.select_column_names
		
		if options[:group_by]
			counts = model.count(
				:all, 
				:conditions => condition_hash[:conditions], 
				:joins => condition_hash[:joins] + " " + model.group_by_mappings[options[:group_by]]["join_relationships"],
				:group => model.group_by_mappings[options[:group_by]]["group_by"],
				:order => options[:order]
			)

			yield(counts, condition_hash[:hidden_fields])
		elsif options[:dashboard]
			items = model.find(:all, :select => select_fields, :conditions => condition_hash[:conditions], :joins => condition_hash[:joins], :order => options[:order])
			yield(items)
		else
			# Is this correct?
			count = model.count(:conditions => condition_hash[:conditions], :select => options[:count_select], :joins => condition_hash[:joins])
			pager = ::ActionController::Pagination::Paginator.new(model, count, options[:per_page] || AppConstant.config["max_per_page"], options[:page])
			items = model.find(:all, :select => (options[:select] || select_fields), :conditions => condition_hash[:conditions], :joins => condition_hash[:joins], :order => options[:order], :limit => pager.items_per_page, :offset => pager.current.offset)

			yield(pager, items, count, condition_hash[:hidden_fields])
		end
	end
end

def search_and_paginate(params, model, order_by, starting_model_selection, current_page, max_per_page, group_by='', options={})
	conditions_and_join_array = search_get_conditions(params, model)

	if options[:extra_conditions]
		conditions_and_join_array[0] += options[:extra_conditions]
	end

	if options[:extra_params]
		conditions_and_join_array[1] += options[:extra_params]
	end

	#Build the conditions and joins from the values returned.
	if conditions_and_join_array.size > 0
		conditions = [conditions_and_join_array[0].join(' and '), *conditions_and_join_array[1]]
		joins = conditions_and_join_array[2].join(' ')
		column_names_array = []
		selects=''
		if selects==''
			selects = model.select_column_names
		else
			selects+=', '+ model.select_column_names
		end
		hidden_query_fields = hidden_fields_build(params,conditions_and_join_array[3])
	end

	full_text_columns = nil
	#
	case group_by
	when ''
		include_fields = nil # [:division, [:lead => :account]]
		if conditions
			count = starting_model_selection.count(:conditions => conditions, :joins => joins)
		else
			count = starting_model_selection.count
		end
		pager = ::Paginator.new(count, max_per_page || AppConstant.config["max_per_page"]) do |offset, per_page|
			if(conditions)
				if(full_text_columns == nil)
					starting_model_selection.find(:all, :include => include_fields, :conditions => conditions, :joins => joins, :select => selects, :limit => per_page, :offset => offset, :order => order_by)
				else
					starting_model_selection.full_text_search(columns?, {}, :joins => joins, :conditions => conditions, :include => include_fields, :limit => per_page, :offset => offset, :order => order_by)	 
				end					 
			else
				starting_model_selection.find(:all, :joins => joins, :limit => per_page, :offset => offset, :order => order_by)
			end
		end
		page = pager.page(current_page)
		yield count, pager, hidden_query_fields, page
	else
		yield starting_model_selection.count(:all, :conditions => conditions, :joins => joins+ " " +model.group_by_mappings[group_by]["join_relationships"], :group => model.group_by_mappings[group_by]["group_by"], :order => "count_all DESC"), hidden_query_fields
	end	
end

def search_get_conditions(params, search_in_model)
	#Remove parameters that do not correspond to any queries
	['commit', 'action', 'controller', 'page', 'per_page', 'sort1', 'sort2', 'sort3', 'tab', ''].each{|k| params.delete k}

	param_hash_table_name=[]
	param_hash_field_name=[]

	#From the params, create two arrays, one with table names and the other with field names
	params.each_key do |x|
	  if params[x].is_a?(Hash)
  		params[x].each_key do |y|
  			unless params[x][y].blank?
  				param_hash_table_name.push(x)
  				param_hash_field_name.push(y)
  			end
  		end
		end
	end

	#Initialize
	old_table = ''
	lookup_field = ''
	select_statement = ''
	current_table_name = ''
	conds = []
	cond_vals = []
	columns = []
	join_sql_statement=[]
	model=nil

	if param_hash_table_name.length>0
		param_hash_table_name.each_index do |each_table_index|
			#For each table do this once
			if old_table != param_hash_table_name[each_table_index]
				old_table = param_hash_table_name[each_table_index]
				#Get the table name, the model name, columns for that model and the join statement if the model is not the search model
				model=search_in_model.join_table_mappings[old_table]["model_name"]
				columns = model.column_names
				if model != search_in_model && search_in_model.join_table_mappings[old_table]["join_relationships"] != ''
					join_sql_statement.push(search_in_model.join_table_mappings[old_table]["join_relationships"])
					current_table_name = old_table
				else
					current_table_name = search_in_model.join_table_mappings[old_table]["table_name"]
				end
			end
			lookup_field = param_hash_field_name[each_table_index]
			lookup_value = params[old_table][lookup_field]

			#If the table columns cointain the search parameter
			if columns.include? lookup_field
				col = model.columns_hash[lookup_field]
				cond_and_vals = search_string_parse(col.type, current_table_name+"."+lookup_field, lookup_value)

				if cond_and_vals
					conds << cond_and_vals[0]
					cond_vals = cond_vals + cond_and_vals[1]
				end
			end
		end
		return [conds, cond_vals, join_sql_statement, param_hash_table_name]
	else
		return []
	end
end

def search_string_parse(col_type, field_string, search_string)
	search_string.strip!
	conjunction_and = '&'
	conjunction_or = '|'
	comparators = ['<=', '>=', '<', '>', '=', '!']
	no_search_comparators = search_string.scan(%r{&|\||<|>|=|!})==[]
	if ((col_type == :string || col_type == :text) && no_search_comparators)
		search_string = "*"+search_string+"*" 
	end
	
	if col_type == :datetime || col_type == :date
	  if no_search_comparators
  		case search_string.downcase
  		when 'today';
  			search_string = Date.today.to_s
  			search_string = '>= '+search_string+'&<'+(search_string.to_date+1).to_s
  		when 'tomorrow';
  			search_string = 1.day.from_now.to_date.to_s
  			search_string = '>= '+search_string+'&<'+(search_string.to_date+1).to_s
  		when 'yesterday';
  			search_string = 1.day.ago.to_date.to_s
  			search_string = '>= '+search_string+'&<'+(search_string.to_date+1).to_s
  		when /next_.*_days/;
  			day_count = search_string.downcase.gsub('next_','').gsub('_days','').to_i+1
  			search_string = '>= '+Date.today.to_s+'&<'+day_count.days.from_now.to_date.to_s
  		when /past_.*_days/;
  			day_count = search_string.downcase.gsub('past_','').gsub('_days','').to_i
  			search_string = '>='+day_count.days.ago.to_date.to_s+'&< '+1.days.from_now.to_date.to_s
  		end
		else
		  search_string.gsub!(/today/i, Date.today.to_s)
  	  search_string.gsub!(/tomorrow/i, 1.day.from_now.to_date.to_s)
  	  search_string.gsub!(/yesterday/i, 1.day.ago.to_date.to_s)
	  end
	end

	search_string.gsub!("%","")
	search_string.gsub!("*","%")

	search_array=search_string.split(%r{\s*&|\|\s*})
	search_array.map!{|x| x.strip}
	search_conjunction=search_string.split(%r{[^&\|]*})
	search_conjunction.map!{|x| if x == conjunction_or then ' OR ' elsif x == conjunction_and then ' AND ' else "" end}
	search_comparator = []

	search_array.each_index do |i|
		if (comparators.include?(search_array[i][0,2]))
			search_comparator.insert(i,search_array[i][0,2])
			search_array[i] = search_array[i][2,search_array[i].length-1]
		elsif (comparators.include?(search_array[i][0,1]))
			search_comparator.insert(i,search_array[i][0,1])
			search_array[i] = search_array[i][1,search_array[i].length-1]
		else
			search_comparator.insert(i,'=')
		end
		search_array[i].strip!		
	end
	
	search_conjunction[0] = ''
	vals = []
	cond = "("
	
	# Refactored the below code -- ayi
	search_array.each_index do |i|
		if search_array[i] == "blank" || search_array[i] == "%blank%"
			cond += search_conjunction[i] + field_string + " "

			if search_comparator[i] == "!"
				cond += "IS NOT NULL"
			else
				cond += "IS NULL"
			end
		elsif col_type == :string || col_type == :text
			cond += search_conjunction[i] + field_string + " "
			
			if search_comparator[i] == "="
				cond += "LIKE ?"
			elsif search_comparator[i] == "!"
				cond += "NOT LIKE ?"
			else
				cond += search_comparator[i] + " ?"
			end

			vals << search_array[i]
		elsif col_type == :integer || col_type == :boolean || col_type == :float
	    cond += search_conjunction[i] + field_string + " "
			
			if search_comparator[i] == '!'
				cond += "!= ?"
			else
				cond += search_comparator[i] + " ?"
			end

			vals << search_array[i]
		elsif col_type == :datetime || col_type == :date
		  cond += search_conjunction[i] + "date(" + field_string + ") "
			
			begin
			  search_array[i] = search_array[i].to_date
			rescue
			  raise ArgumentError.new("Invalid date")
		  end
				
			if search_comparator[i] == '!'
				cond += "!= ?"
			else
				cond += search_comparator[i] + " ?"
			end

			vals << search_array[i]
		end
	end
	
	cond += ")"
	
	if cond == "()" # No conditions were found
		return nil
	else
		return [cond, vals]
	end

end


