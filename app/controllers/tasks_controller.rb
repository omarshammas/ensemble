class TasksController < ApplicationController
  before_filter :verify_parent

  def verify_parent
    @user = User.find_by_id(params[:user_id]) unless params[:user_id].blank?
    return redirect_to :home if @user != current_user || @user.nil?
  end
 
  def index
    @tasks = @user.nil? ? Task.all : @user.tasks
    
    respond_to do |format|
      format.html
      format.json { render json: @tasks }
    end
  end

  def show
    @task = Task.find(params[:id])
    @comments = @task.comments('created_at asc')
    @suggestions = @task.suggestions.where(sent: false).order('vote_count desc')
    @processed_suggestions = @task.suggestions.where(sent: true, accepted: [-1,1]).order('created_at desc')
    @preferences = @task.preferences('created_at desc')
    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end

  def new
    @task = Task.new
    #TODO: Create 5 Turker hits
    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        @task.iterations.create!()
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
end
