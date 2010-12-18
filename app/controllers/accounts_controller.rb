class AccountsController < ApplicationController
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
    search_and_paginate(params, Account, :per_page => AppConstant.config["max_per_page"], :order => order, :page => params[:page]) do |pager, items, count, hidden_query_fields|
      @count = count
      @pager = pager
      @items = items
    end
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect_to :action => 'show', :id => @account
    else
      render :action => 'edit'
    end
  end

  def destroy
    Account.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
