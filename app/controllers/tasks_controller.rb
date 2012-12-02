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
    @user = current_user
    @task = Task.find(params[:id])

    return redirect_to :home unless @task.user == @user

    @suggestions = @task.suggestions.where(sent: true).order('updated_at desc')
    @hits = @task.hits

    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end

  def new
    @task = Task.new
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
        base_url = "#{request.protocol}#{request.host_with_port}/"
        for i in 1..5
          @task.createHIT(base_url)
        end

        format.html { redirect_to :home, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @task = Task.find(params[:id])
    return redirect_to :home unless @task.user == @user

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to user_task_path(@user,@task), notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task = Task.find(params[:id])
    return redirect_to :home unless @task.user == @user

    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
end
