class UserController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
  	return redirect_to user_tasks_path(current_user)
  end

end
