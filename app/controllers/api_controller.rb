class ApiController < ApplicationController

  Pusher.app_id = '30959'
  Pusher.key = '9ceb5ef670c4262bfbca'
  Pusher.secret = '959771cb4f1e0062256a'

  
  def post_up_vote
    suggestion = Suggestion.find(params[:suggestion_id])
    #TODO Don't hardcode user
    user = User.find(1);
    vote = Vote.new(:suggestion_id => suggestion.id, :user_id => user.id)
    suggestion.vote_count = suggestion.vote_count+1
    if vote.save && suggestion.save
      task = suggestion.task
      votes = task.suggestions.order('vote_count desc')
      Pusher["ensemble-" + "#{task.id}"].trigger('post_up_vote', votes)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def post_suggestion
    task = Task.find(params[:task_id])
    suggestion = Suggestion.new
    suggestion.task_id = task.id
    #TODO Don't hardcode user
    user = User.find(1);
    suggestion.user_id = user.id
    suggestion.body = params[:body]
    suggestion.acceptance_status = 0
    suggestion.vote_status = 0
    suggestion.vote_count = 0
    #TODO set iteration for comment
    payload = suggestion.attributes
    payload[:user] = user.attributes

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
    #TODO Don't hardcode user
    user = User.find(1);
    comment.user_id = user.id
    comment.body = params[:body]
    #TODO set iteration for comment
    
    payload = comment.attributes
    payload[:user] = user.attributes

    if comment.save
      Pusher["ensemble-" + "#{task.id}"].trigger('post_comment', payload)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
    def authenticate
      #TODO Don't hardcode user
      user = User.find(1);
      if !user.nil?
        auth = Pusher[params[:channel_name]].authenticate(params[:socket_id],
          :user_id => user.id,
          :user => user.attributes
        )
        render :json => auth
      else
        render :text => "Not authorized", :status => '403'
      end
  end

end
