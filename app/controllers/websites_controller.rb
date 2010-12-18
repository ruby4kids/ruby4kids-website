class WebsitesController < ApplicationController
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

    search_and_paginate(params, Website, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @website = Website.find(params[:id])
  end

  def new
    @website = Website.new
  end

  def create
    @website = Website.new(params[:website])
    if @website.save
      flash[:notice] = 'Website was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @website = Website.find(params[:id])
  end

  def update
    @website = Website.find(params[:id])
    if @website.update_attributes(params[:website])
      flash[:notice] = 'Website was successfully updated.'
      redirect_to :action => 'show', :id => @website
    else
      render :action => 'edit'
    end
  end

  def destroy
    Website.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
