class TurkController < ApplicationController
  before_filter :authenticate_turk!


  MIN_THRESHOLD = -2

  def tasks
    if !current_turker.instructed
      redirect "/instructions?task_id=#{params[:id]}"
    end
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
  
  def instructions
    step = session[:step].nil? ? 1: session[:step]
    @image_url = "#{step}.png"
    if step == 1
      @title = "Overview"
      @description = "An anonymous requestor will provide you with a picture 
      and a description of an article of clothing he or she desires. Your job is 
      to to work with others to provide clothing recommendations for the requestor
      using the interface picture below"
    elsif step == 2
      @title = "Requestor Task"
      @description = "This section displays a picture of the requested article
      of clothing along with a description. You can click the thumbnail to view
      a larger image"
    elsif step == 3
      @title = "Chat"
      @description = "As previously mentioned, you will be working with others
      to create suggestions for the requestor. Use the chat to discuss ideas and
      viewpoints with other fashionistas!"
    elsif step == 4
      @title = "Make a Suggestion"
      @description = "Click on the (+) icon next to the 'Suggestions' to make a
      make a suggestion. When making a suggestion paste the URL of the product link
      and use the arrows to select the preview image of choice along with filling
      in the rest of the forms"
    elsif step == 5
      @title = "Vote on Suggestions"
      @description = "This section lists all unsent suggestions. You can place an 
      up vote on a suggestion that you like, or a down vote on a suggestion you 
      dislike. When a suggestion receives too many down votes it is removed from the
      list. If it receives enough up votes it will be sent to the requestor"
    elsif step == 6
      @title = "Send a Suggestion"
      @description = "The alert below will pop up when a suggestion has been sent to
      the requestor. The requestor will either accept the suggestion or reject it 
      in will be displayed in the feedback section"
     elsif step == 7
      @title = "Requestor Feedback"
      @description = "If a suggestion is rejected it is displayed here. Each rejected 
      suggestion contains a rating and a comment from the requester"
     end
     if(step == 7)
      task = Task.find(params[:task_id])
      task.update_attributes(:instructed => true)
      #TODO link them to task
     else
       @next_step = "/turk/instructions?task_id=#{params[:task_id]}"
     end
     #session[:step] = step + 1
     
  end
  
end
