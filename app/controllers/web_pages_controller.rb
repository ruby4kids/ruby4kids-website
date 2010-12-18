class WebPagesController < ApplicationController
  verify :method => :post, :only => [ :destroy, :create, :update ], :redirect_to => { :action => :list }
  include SearchAndPaginate
  helper :params
  layout "application"
  
  before_filter :set_popups
  
  def set_popups
    @websites = Website.find(:all).map {|w| [w.name, w.id]}
    @page_layouts = PageLayout.find(:all).map {|l| [l.name, l.id]}
  end
  
    
  def index
    list
    render :action => 'list'
  end
  
  def list
    order = (params[:order] || "id").gsub(/\W+/, "") + " desc"

    search_and_paginate(params, WebPage, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @web_page = WebPage.find(params[:id])
  end

  def new
    @web_page = WebPage.new
  end

  def create
    @web_page = WebPage.new(params[:web_page])
    if @web_page.save
      flash[:notice] = 'WebPage was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @web_page = WebPage.find(params[:id])
  end

  def update
    @web_page = WebPage.find(params[:id])
    if @web_page.update_attributes(params[:web_page])
      flash[:notice] = 'WebPage was successfully updated.'
      redirect_to :action => 'show', :id => @web_page
    else
      render :action => 'edit'
    end
  end

  def destroy
    WebPage.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
