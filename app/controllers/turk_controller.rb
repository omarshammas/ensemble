class TurkController < ApplicationController
  before_filter :authenticate_turk!

  layout "turkers"

  def first
  	@task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where(sent: false).order('vote_count desc')
    @history = @task.suggestions.where('sent = :sent AND accepted IS NOT NULL',{:sent => true}).order('created_at desc')
  end

  def second
  	@task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where(sent: false).order('vote_count desc')
    @history = @task.suggestions.where('sent = :sent AND accepted IS NOT NULL',{:sent => true}).order('created_at desc')
  end
end
