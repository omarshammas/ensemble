class TurkController < ApplicationController
  before_filter :authenticate_turk!

  MIN_THRESHOLD = -2
  def tasks
    @task = Task.find(params[:id])
    if (@task.interface == 'first' && !current_turk.instructed_first) || (@task.interface == 'second' && !current_turk.instructed_second)
      return redirect_to "/turk/instructions?task_id=#{@task.id}&interface=#{@task.interface}"
    end
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
    interface = params[:interface]
    if interface == 'first'
      step = session[:first_ui_step].nil? ? 1: session[:first_ui_step]
      @image_url = "first/#{step}.png"
      if step == 1
        @title = "Overview"
        @description = "An anonymous requestor will provide you with a picture
      and a description of an article of clothing he or she desires. Your job is
      to to work with others to provide clothing recommendations for the requestor
      using the interface displayed below"
      elsif step == 2
        @title = "Requestor Task"
        @description = "This section displays a picture and a description of
        of the desired article of clothing. You can click the thumbnail to view
      a larger image"
      elsif step == 3
        @title = "Chat"
        @description = "As previously mentioned, you will be working with others
      to create suggestions for the requestor. Use the chat to discuss ideas and
      viewpoints with other fashionistas!"
      elsif step == 4
        @title = "Make a Suggestion"
        @description = "Click on the (+) icon next to the 'Suggestions' to make a
      make one. When making a suggestion, paste the URL of the product into 
      the product link field. As you fill in the rest of the details, all
      the images on the products website will be loaded. Use the arrows to select
      the correct product preview image"
      elsif step == 5
        @title = "Vote on Suggestions"
        @description = "This section lists all unsent suggestions. You can place an
      up vote on a suggestion that you like, or a down vote on a suggestion that you
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
      suggestion contains a rating and a comment from the requestor. If the requestor acepted
      the article of clothing the task will close"
      end
      if(step == 7)
        turk = current_turk
        turk.instructed_first = true
        turk.save
        @button_title = "Start!"
        @next_step = "/turk/tasks/#{params[:task_id]}"
      else
        @button_title = "Continue"
        @next_step = "/turk/instructions?task_id=#{params[:task_id]}&interface=#{params[:interface]}"
        session[:first_ui_step] = step + 1
      end
    else
      step = session[:second_ui_step].nil? ? 1: session[:second_ui_step]
      @image_url = "second/#{step}.png"
      if step == 1
        @title = "Overview"
        @description = "An anonymous requestor will provide you with a picture
      and a description of an article of clothing he or she desires. Your job is
      to to work with others to provide clothing recommendations for the requestor
      using the interface displayed below"
      elsif step == 2
        @title = "Requestor Task"
        @description = "This section displays a picture and a description of
        of the desired article of clothing. You can click the thumbnail to view
      a larger image"
      elsif step == 3
        @title = "Make a Suggestion"
        @description = "Click on the (+) icon next to the 'Suggestions' to make a
      make one. When making a suggestion, paste the URL of the product into 
      the product link field. As you fill in the rest of the details, all
      the images on the products website will be loaded. Use the arrows to select
      the correct product preview image"
      elsif step == 4
        @title = "Vote/Comment on Suggestions"
        @description = "By clicking on one of the boxes under 'Suggestions' you can
      up vote, down vote, view pros/cons and add pros/cons to a suggestion.
      When a suggestion receives too many down votes it is removed from the
      list. If it receives enough up votes it will be sent to the requestor"
      elsif step == 5
        @title = "Send a Suggestion"
        @description = "The alert below will pop up when a suggestion has been sent to
      the requestor. The requestor will either accept the suggestion or reject it"
      elsif step == 6
        @title = "Requestor Feedback"
        @description = "If a suggestion is rejected it is displayed here. Each rejected
      suggestion contains a rating and a comment from the requestor. If the requestor acepted
      the article of clothing the task will close"
      end
      if(step == 6)
        turk = current_turk
        turk.instructed_second = true
        turk.save
        @button_title = "Start!"
        @next_step = "/turk/tasks/#{params[:task_id]}"
      else
        @button_title = "Continue"
        @next_step = "/turk/instructions?task_id=#{params[:task_id]}&interface=#{params[:interface]}"
        session[:second_ui_step] = step + 1
      end
    end
  end

end
