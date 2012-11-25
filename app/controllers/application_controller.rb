class ApplicationController < ActionController::Base
  #protect_from_forgery

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :current_turk

  private  
    def current_user  
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]  
    end

    def current_turk
      @current_turk ||= Turk.find_by_id(session[:turk_id]) if session[:turk_id]
    end
    
    def user_signed_in?
      return 1 if current_user 
    end
      
    def authenticate_user!
      if !current_user
        flash[:error] = 'You need to sign in before accessing this page!'
        redirect_to authenticate_path
      end
    end    

    def authenticate_turk!
      if !current_turk
        t = Turk.create
        session[:turk_id] = t.id
      end
    end
end
