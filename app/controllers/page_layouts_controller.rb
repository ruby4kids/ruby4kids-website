class PageLayoutsController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ], :redirect_to => { :action => :list }
  include SearchAndPaginate
  helper :params
  layout "application"
  
  before_filter :populate_popups
  
  def populate_popups
    @websites = Website.find(:all).map {|w| [w.name, w.id]}
  end
  
    
  def index
    list
    render :action => 'list'
  end
  
  def list
    order = (params[:order] || "id").gsub(/\W+/, "") + " desc"

    search_and_paginate(params, PageLayout, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @page_layout = PageLayout.find(params[:id])
  end

  def new
    @page_layout = PageLayout.new
  end

  def create
    @page_layout = PageLayout.new(params[:page_layout])
    if @page_layout.save
      flash[:notice] = 'PageLayout was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page_layout = PageLayout.find(params[:id])
  end

  def update
    @page_layout = PageLayout.find(params[:id])
    if @page_layout.update_attributes(params[:page_layout])
      flash[:notice] = 'PageLayout was successfully updated.'
      redirect_to :action => 'show', :id => @page_layout
    else
      render :action => 'edit'
    end
  end

  def destroy
    PageLayout.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
