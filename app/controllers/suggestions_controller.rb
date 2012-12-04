class SuggestionsController < ApplicationController
  before_filter :verify_parent

  def verify_parent
    @user = User.find_by_id(params[:user_id]) unless params[:user_id].blank?
    return redirect_to :home if @user != current_user || @user.nil?

    @task = Task.find(params[:task_id]) unless params[:task_id].blank?
    return redirect_to :home if @task.user != @user || @task.nil?
  end

  def show
    @suggestion = Suggestion.find(params[:id])
    return redirect_to :home unless @suggestion.task == @task

    @pros = @suggestion.points.where(isPro:true)
    @cons = @suggestion.points.where(isPro:false)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @suggestion }
    end
  end

end
