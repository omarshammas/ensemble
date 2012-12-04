class TurkController < ApplicationController
  before_filter :authenticate_turk!


  MIN_THRESHOLD = -2

  def tasks
    @task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where('sent = :sent AND vote_count > :min_count',{:sent => false, :min_count => MIN_THRESHOLD}).order('vote_count desc')
    @history = @task.suggestions.where('sent = :sent AND accepted IS NOT NULL',{:sent => true}).order('created_at desc')
    
    if @task.interface == 'first'
      return render layout: 'turkers_first', action: 'first'
    elsif @task.interface == 'second'
      return render layout: 'turkers_second', action: 'second'
    end
  end
end
