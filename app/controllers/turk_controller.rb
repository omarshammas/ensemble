class TurkController < ApplicationController
  before_filter :authenticate_turk!

  layout "turkers"

  def tasks
  	@task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where(vote_status: 0).order('vote_count desc')
    @processed_suggestions = @task.suggestions.where('vote_status <> 0 AND acceptance_status <> 0').order('created_at desc')
    @preferences = @task.preferences('created_at desc')
  end
end
