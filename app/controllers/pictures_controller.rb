class PicturesController < ApplicationController
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

    search_and_paginate(params, Picture, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @picture = Picture.find(params[:id])
  end
  

  def new
    @picture = Picture.new
  end

  def create
    @picture = Picture.new(params[:picture])
    if @picture.save
      flash[:notice] = 'Picture was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def destroy
    picture = Picture.find(params[:id])
    expire_page :controller => 'public', :action => 'picture', :id => picture.id
    picture.destroy
    redirect_to :action => 'list'
  end
end
