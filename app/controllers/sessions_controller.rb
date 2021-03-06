class SessionsController < ApplicationController
  def authenticate
  	return redirect_to "/users/#{current_user.id}/tasks" unless current_user.nil?
  	@user = User.new
  end

  def login
  	@user = User.find_by_email(params[:user][:email])

  	if @user.nil?
  		redirect_to :authenticate, notice: 'Email is not recognized.'
    else
  		session[:user_id] = @user.id
  		redirect_to "/users/#{current_user.id}/tasks"
  	end
  end

  def signup
    @user = User.find_by_email(params[:email])
    return redirect_to :authenticate, notice: 'Email already exists.' unless @user.nil?
    
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to "/users/#{current_user.id}/tasks"
    else
      redirect_to :authenticate, notice: @user.errors.messages
    end 
  end

  def destroy
  	session[:user_id] = nil
    redirect_to :authenticate
  end
end
