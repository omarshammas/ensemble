class TurkController < ApplicationController
  before_filter :authenticate_turk!

  layout "turkers"

  MIN_THRESHOLD = -2

  def task
    @task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where('sent = :sent AND vote_count > :min_count',{:sent => false, :min_count => MIN_THRESHOLD}).order('vote_count desc')
    @history = @task.suggestions.where('sent = :sent AND accepted IS NOT NULL',{:sent => true}).order('created_at desc')
    
    return render @task.interface
  end
end
