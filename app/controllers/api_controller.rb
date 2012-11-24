class ApiController < ApplicationController

  Pusher.app_id = '30959'
  Pusher.key = '9ceb5ef670c4262bfbca'
  Pusher.secret = '959771cb4f1e0062256a'

  def post_up_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk
    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.increment_counter :vote_count, suggestion.id 
      task = suggestion.task
      votes = task.suggestions.order('vote_count desc')
      p votes
      Pusher["ensemble-" + "#{task.id}"].trigger('update_suggestion_votes', votes)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end

  def post_down_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk
    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.decrement_counter :vote_count, suggestion.id
      task = suggestion.task
      votes = task.suggestions.order('vote_count desc')
      Pusher["ensemble-" + "#{task.id}"].trigger('update_suggestion_votes', votes)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def post_suggestion
    task = Task.find(params[:task_id])
    suggestion = Suggestion.new
    suggestion.task_id = task.id
    
    turk = current_turk
    suggestion.suggestable = turk
    suggestion.body = params[:body]
    suggestion.acceptance_status = 0
    suggestion.vote_status = 0
    suggestion.vote_count = 0
    #TODO set iteration for comment

    payload = suggestion.attributes
    payload[:turk] = turk.attributes
    if suggestion.save
      Pusher["ensemble-" + "#{task.id}"].trigger('post_suggestion', payload)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def post_comment
    task = Task.find(params[:task_id])
    comment = Comment.new
    comment.task_id = task.id
    
    turk = current_turk
    comment.commentable = turk
    comment.body = params[:body]
    #TODO set iteration for comment
    
    payload = comment.attributes
    payload[:turk] = turk.attributes
    payload[:task] = task.attributes
    if comment.save
      Pusher["ensemble-" + "#{task.id}"].trigger('post_comment', payload)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def authenticate
    turk = current_turk
    if !turk.nil?
      auth = Pusher[params[:channel_name]].authenticate(params[:socket_id],
        :turk => turk.attributes
      )
      render :json => auth
    else
      render :text => "Not authorized", :status => '403'
    end
  end

end
