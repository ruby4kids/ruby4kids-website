class <%= controller_class_name %>Controller < ApplicationController
  verify :method => :post, :only => [ :destroy<%= suffix %>, :create<%= suffix %>, :update<%= suffix %> ], :redirect_to => { :action => :list<%= suffix %> }
  include SearchAndPaginate
  helper :params
  layout "application"
    
<%- unless suffix -%>
  def index
    list
    render :action => 'list'
  end
  
<%- end -%>
<%- for action in unscaffolded_actions -%>
  def <%= action %><%= suffix %>
  end
  
<%- end -%>
  def list<%= suffix %>
    order = (params[:order] || "id").gsub(/\W+/, "") + " desc"

    search_and_paginate(params, <%= class_name %>, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  def new<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.new
  end

  def create<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.new(params[:<%= singular_name %>])
    if @<%= singular_name %>.save
      flash[:notice] = '<%= model_name %> was successfully created.'
      redirect_to :action => 'list<%= suffix %>'
    else
      render :action => 'new<%= suffix %>'
    end
  end

  def edit<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  def update
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
    if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
      flash[:notice] = '<%= model_name %> was successfully updated.'
      redirect_to :action => 'show<%= suffix %>', :id => @<%= singular_name %>
    else
      render :action => 'edit<%= suffix %>'
    end
  end

  def destroy<%= suffix %>
    <%= model_name %>.find(params[:id]).destroy
    redirect_to :action => 'list<%= suffix %>'
  end
end
