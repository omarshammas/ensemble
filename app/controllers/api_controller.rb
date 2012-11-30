class ApiController < ApplicationController

  Pusher.app_id = '30959'
  Pusher.key = '9ceb5ef670c4262bfbca'
  Pusher.secret = '959771cb4f1e0062256a'

  THRESHOLD = 2

  def post_up_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk
    if(suggestion.votes.where(:turk_id => turk.id).count >= 1)
      task = suggestion.task
      Pusher["ensemble-" + "#{task.id}"].trigger('vote_already_cast', task)
      render :text => "failed"
      return
    end 
    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.increment_counter :vote_count, suggestion.id 
      task = suggestion.task
      suggestions = task.suggestions.where(sent: false).order('vote_count desc')
      Pusher["ensemble-" + "#{task.id}"].trigger('update_suggestion_votes', suggestions)
      render :text => "sent"

      #Get User and Send SMS
      if suggestion.vote_count >= THRESHOLD
        user = task.user
        user.send_message suggestion.product_link
        user.send_message "$#{suggestion.price} - #{suggestion.product_name} from #{suggestion.retailer}"
      end
    else
      render :text => "failed"
    end
  end

  def post_down_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk
    if(suggestion.votes.where(:turk_id => turk.id).count >= 1)
      task = suggestion.task
      Pusher["ensemble-" + "#{task.id}"].trigger('vote_already_cast', task)
      render :text => "failed"
      return
    end 
    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.decrement_counter :vote_count, suggestion.id
      task = suggestion.task
      suggestions = task.suggestions.where(sent: false).order('vote_count desc')
      Pusher["ensemble-" + "#{task.id}"].trigger('update_suggestion_votes', suggestions)
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
    # suggestion.accepted = 0
    # suggestion.sent = false
    suggestion.vote_count = 0
    suggestion.image_url = params[:image_url]
    suggestion.retailer = params[:retailer]
    suggestion.product_link = params[:product_link]
    suggestion.product_name = params[:product_name]
    suggestion.price = params[:price]
    suggestion.iteration_id = task.current_iteration.id unless task.current_iteration.nil?
    #TODO set iteration for comment
    payload = suggestion.attributes
    payload[:turk] = turk.attributes
    if suggestion.save
      Pusher["ensemble-" + "#{task.id}"].trigger('post_suggestions', payload)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def post_preference
    task = Task.find(params[:task_id])
    turk = current_turk;
    preference_body = params[:preference_body]
    pref = Preference.new(:turk_id => turk.id, :body => preference_body, :task_id => task.id)
    if pref.save 
      prefs = task.preferences.order('created_at desc')
      Pusher["ensemble-"+"#{task.id}"].trigger('update_preferences', prefs)
      render :text => 'sent'
    else
      render :text => "failed"
    end
  end
  
  def remove_preference
    task = Task.find(params[:task_id])
    pref = Preference.find(params[:preference_id])
    pref.destroy()
    prefs = task.preferences.order('created_at desc')
    Pusher["ensemble-"+"#{task.id}"].trigger('update_preferences', prefs)
    render :text => 'sent'
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

  def sms

=begin
  {"AccountSid"=>"ACebf8674db0f1e95deec913097e855dee", "Body"=>"Sent from your Twilio trial account - shoo bro", "ToZip"=>"01801", "FromState"=>"MA", "ToCity"=>"WOBURN", "SmsSid"=>"SM58e0207cc3294ccca7905bc28bb6e5f8", "ToState"=>"MA", "To"=>"+13392984356", "ToCountry"=>"US", "FromCountry"=>"US", "SmsMessageSid"=>"SM58e0207cc3294ccca7905bc28bb6e5f8", "ApiVersion"=>"2010-04-01", "FromCity"=>"BOSTON", "SmsStatus"=>"received", "From"=>"+16177211618", "FromZip"=>"02110", "controller"=>"turk", "action"=>"sms"}
=end
    phone_number = params[:From]
    body = params[:Body]

    user = User.find_by_phone_number(phone_number)
    p "User #{user}"
    return render text: '<Response>' if user.nil?
  
    task = user.tasks.where(finished: false).first
    p "Task #{task}"
    return render text: '<Response>' if task.nil?

    p "Body #{body}"
    if body == "end;"
      task.close()
      Pusher["ensemble-" + "#{task.id}"].trigger('task_finished', payload)
    else
      comment = Comment.new
      comment.task_id = task.id
      comment.commentable = user
      comment.body = body
      
      payload = comment.attributes
      payload[:user] = user.attributes
      payload[:task] = task.attributes
      if comment.save
        Pusher["ensemble-" + "#{task.id}"].trigger('post_comment', payload)
      end
    end

    return render text: '<Response>'
  end

end
