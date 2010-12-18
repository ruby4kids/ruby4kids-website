class AttachmentsController < ApplicationController
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

    search_and_paginate(params, Attachment, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @attachment = Attachment.find(params[:id])
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
      flash[:notice] = 'Attachment was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])
    if @attachment.update_attributes(params[:attachment])
      flash[:notice] = 'Attachment was successfully updated.'
      redirect_to :action => 'show', :id => @attachment
    else
      render :action => 'edit'
    end
  end

  def destroy
    Attachment.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
