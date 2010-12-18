class PeopleController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ], :redirect_to => { :action => :list }
  include SearchAndPaginate
  helper :params
  layout "application"
    
  def index
    list
    render :action => 'list'
  end
  
  def list
    order = (params[:order] || "id").gsub(/\W+/, "") + " desc"

    search_and_paginate(params, Person, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    debugger
    if @person.save
      flash[:notice] = 'Person was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
