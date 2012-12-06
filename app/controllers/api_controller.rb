class ApiController < ApplicationController

  Pusher.app_id = '30959'
  Pusher.key = '9ceb5ef670c4262bfbca'
  Pusher.secret = '959771cb4f1e0062256a'

  UP_THRESHOLD = 2
  MIN_THRESHOLD = -2
  CHANNEL_PREFIX = 'presence-ensemble-'
  NUMBER_OF_TASKS = 4

  def get_redeem_code
    task = Task.find params[:task_id]
    turk = current_turk
    hit_count = task.hits.where(:turk_id => turk.id).count
    task_count = task.votes.where(:turk_id => turk.id).count+
                 task.suggestions.where(:suggestable_id => turk.id).count+
                 task.points.where(:turk_id => turk.id).count
                 
    if task_count >= NUMBER_OF_TASKS * (hit_count+1) || (task.finished && task_count > 0)
      #TODO NEED TO FIX RACE CONDITION!!!!!
      hit = task.hits.where("turk_id IS NULL").first
      hit.update_attributes(:turk_id => turk.id)
      task.createHIT(ENV["ENSEMBLE_HOSTNAME"]) unless task.finished
      render json: { status: 'success', code: hit.code }
    else
      render json: { status: 'failed', min_tasks:NUMBER_OF_TASKS, count:task_count - (NUMBER_OF_TASKS * hit_count) }
    end
  end

  def post_up_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk

    #if already voted
    return render json: { status: "already_voted"} if suggestion.votes.where(:turk_id => turk.id).count >= 1
    
    return render json: { status: "waiting-for-response"} if !suggestion.task.suggestions.where('sent = :sent AND accepted IS NULL',{:sent => true}).first.nil?
    
    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.increment_counter :vote_count, suggestion.id
      suggestion.reload
      task = suggestion.task
      #Send User an SMS with the suggestion
      if suggestion.vote_count >= UP_THRESHOLD and not suggestion.sent 
        user = task.user
        user.send_message "#{request.protocol}#{request.host_with_port}#{user_task_suggestion_path(user, task, suggestion)}"
        suggestion.update_attribute :sent, true
        Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('update_sent_suggestion', suggestion)
      end
      suggestions = task.suggestions.where('sent = :sent AND vote_count > :min_count',{:sent => false, :min_count => MIN_THRESHOLD}).order('vote_count desc')
      Pusher[CHANNEL_PREFIX  + "#{task.id}"].trigger('update_suggestions', suggestions)      
      render json: { status: "succes"}
    else
      render json: { status: "failed"}
    end
  end

  def post_down_vote
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk

    #if already voted
    return render json: { status: "already_voted"} if suggestion.votes.where(:turk_id => turk.id).count >= 1
    #if waiting for a response
    return render json: { status: "waiting-for-response"} if !suggestion.task.suggestions.where('sent = :sent AND accepted IS NULL',{:sent => true}).first.nil?

    vote = Vote.new suggestion_id: suggestion.id, turk_id: turk.id
    if vote.save
      Suggestion.decrement_counter :vote_count, suggestion.id
      task = suggestion.task
      suggestions = task.suggestions.where('sent = :sent AND vote_count > :min_count',{:sent => false, :min_count => MIN_THRESHOLD}).order('vote_count desc')
      Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('update_suggestions', suggestions)
      render json: { status: "success"}
    else
      render json: { status: "failed"}
    end
  end

  def post_point
    suggestion = Suggestion.find params[:suggestion_id]
    turk = current_turk

    return render json: {status: 'failed'} if suggestion.nil? or turk.nil? or params[:isPro].nil? or params[:body].nil?

    point = Point.new isPro: params[:isPro], body: params[:body], suggestion_id: suggestion.id, turk_id: turk.id
    if point.save
      Pusher[CHANNEL_PREFIX + "#{suggestion.task_id}"].trigger('point_added', point)
      render json: { status: 'success', point:point.to_json }
    else
      render json: { status: 'failed'}
    end
  end
  
  def post_suggestion
    task = Task.find(params[:task_id])
    suggestion = Suggestion.new
    suggestion.task_id = task.id
    turk = current_turk
    suggestion.suggestable = turk
    suggestion.vote_count = 0
    suggestion.image_url = params[:image_url]
    suggestion.retailer = params[:retailer]
    suggestion.product_link = params[:product_link]
    suggestion.product_name = params[:product_name]
    suggestion.price = params[:price]
    
    if suggestion.save
      suggestions = task.suggestions.where('sent = :sent AND vote_count > :min_count',{:sent => false, :min_count => MIN_THRESHOLD}).order('vote_count desc')
      Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('update_suggestions', suggestions)
      render json: { status: "success"}
    else
      render json: { status: "failed"}
    end
  end

  def get_suggestion
    suggestion = Suggestion.find(params[:suggestion_id])
    pros = Point.where(suggestion_id: suggestion.id, isPro:true)
    cons = Point.where(suggestion_id: suggestion.id, isPro:false)
    render json: { suggestion: suggestion.to_json, pros: pros.to_json, cons: cons.to_json }
  end
  
  def suggestion_response
    task = Task.find(params[:task_id])
    suggestion = Suggestion.find(params[:id])
    if suggestion.update_attributes(params[:suggestion])
      if !suggestion.accepted
        Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('suggestion_rejected', suggestion)
      else
        task.update_attributes(:finished => true)
        #TODO Close all open hits
        Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('suggestion_accepted', suggestion)
      end
    else
      render :text => "failed"
    end
      redirect_to :home
  end
  
  def post_comment
    task = Task.find(params[:task_id])
    comment = Comment.new
    comment.task_id = task.id
    turk = current_turk
    comment.commentable = turk
    comment.body = params[:body]
    payload = comment.attributes
    payload[:turk] = turk.attributes
    payload[:task] = task.attributes
    if comment.save
      Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('post_comment', payload)
      render :text => "sent"
    else
      render :text => "failed"
    end
  end
  
  def authenticate
    turk = current_turk
    if !turk.nil?
      auth = Pusher[params[:channel_name]].authenticate(params[:socket_id],
        :user_id => turk.id
      )
      render :json => auth
    else
      render :text => "Not authorized", :status => '403'
    end
  end
  
  def webhook
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      webhook.events.each do |event|
        case event["name"]
        when 'member_removed'
          # task_id = event["channel"].split('-').last.to_i
          # logger.info "Creating HIT for task with ID #{task_id.to_s}"
          # Task.find(task_id).createHIT(ENV["ENSEMBLE_HOSTNAME"])
        end
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end


  def sms
=begin
  {"AccountSid"=>"ACebf8674db0f1e95deec913097e855dee", "Body"=>"Sent from your Twilio trial account - shoo bro", "ToZip"=>"01801", "FromState"=>"MA", "ToCity"=>"WOBURN", "SmsSid"=>"SM58e0207cc3294ccca7905bc28bb6e5f8", "ToState"=>"MA", "To"=>"+13392984356", "ToCountry"=>"US", "FromCountry"=>"US", "SmsMessageSid"=>"SM58e0207cc3294ccca7905bc28bb6e5f8", "ApiVersion"=>"2010-04-01", "FromCity"=>"BOSTON", "SmsStatus"=>"received", "From"=>"+16177211618", "FromZip"=>"02110", "controller"=>"turk", "action"=>"sms"}
=end
    phone_number = params[:From]
    body = params[:Body]

    user = User.find_by_phone_number(phone_number)
    return render text: '<Response>' if user.nil?
  
    task = user.tasks.where(finished: false).first
    return render text: '<Response>' if task.nil?

    if body == "end;"
      task.close()
      Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('task_finished', payload)
    else
      comment = Comment.new
      comment.task_id = task.id
      comment.commentable = user
      comment.body = body
    
      if comment.save
        payload = comment.attributes
        payload[:user] = user.attributes
        payload[:task] = task.attributes
        Pusher[CHANNEL_PREFIX + "#{task.id}"].trigger('post_comment', payload)
      end
    end

    return render text: '<Response>'
  end

end
