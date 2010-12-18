class RolesController < ApplicationController
	verify :method => :post, :only => [ :destroy, :create, :update, :add_account, :remove_account ], :redirect_to => { :action => :list }
	
	def auto_complete_for_account_username
		@accounts = Account.find(:all, :conditions => ["accounts.status = 'Active' AND accounts.username LIKE ?", params[:account][:username] + "%"],
		                          :limit => 20)
		render :inline => "<%= auto_complete_result @accounts, 'username' %>"
	end
	
	def add_account
		@account = Account.find_by_username(params[:account][:username])
		@role = Role.find(params[:id]) 
		if @account && @role
			@account.roles << @role unless @account.roles.include? @role
		else
			flash[:notice] = 'Username was not found'
		end
		
		respond_to do |fmt|
			fmt.html {redirect_to :action => 'show', :id => @role}
			fmt.js
		end
	end
	
	def remove_account
		@role = Role.find(params[:id])
		@account = @role.accounts.find(params[:account_id])
		@role.accounts.delete(@account)
		
		respond_to do |fmt|
			fmt.html {redirect_to :action => "show", :id => @role.id}
			fmt.js
		end
	end
	
	def add_right
		@role = Role.find(params[:id])
		@right = Right.find(params[:right][:id])
		
		if @role && @right
			@role.rights << @right
		else
			flash[:notice] = "Right not found"
		end
		
		respond_to do |fmt|
			fmt.html {redirect_to :action => "show", :id => @role.id}
			fmt.js
		end
	end
	
	def remove_right
		@role = Role.find(params[:id])
		@right = Right.find(params[:right_id])

		if @role && @right
			@role.rights.delete(@right)
		else
			flash[:notice] = "Right not found"
		end
		
		respond_to do |fmt|
			fmt.html {redirect_to :action => "show", :id => @role.id}
			fmt.js
		end
	end
	
	def list
	  @roles = Role.find(:all, :order => "name")
  end
  

	def show
		@role = Role.find(params[:id])
		@all_rights = Right.find(:all, :order => "name")
	end

	def new
		@Role = Role.new
	end

	def create
		@role = Role.new(params[:role])
		
		if @role.save
			flash[:notice] = 'Role was successfully created.'
			redirect_to :action => 'index'
		else
			render :action => 'new'
		end
	end

	def edit
		@role = Role.find(params[:id])
	end

	def update
		@role = Role.find(params[:id])
		
		if @role.update_attributes(params[:Role])
			flash[:notice] = 'Role was successfully updated.'
			redirect_to :action => 'show', :id => @role
		else
			render :action => 'edit'
		end
	end

	def destroy
		Role.find(params[:id]).destroy
		
		respond_to do |fmt|
			fmt.html {redirect_to :action => 'list'}
			fmt.js {@id = params[:id].to_s}
		end
	end
end