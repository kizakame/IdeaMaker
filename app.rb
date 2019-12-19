require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions

require 'open-uri'
require 'nokogiri'
require 'sinatra/activerecord'
require './models'
require "./show_table_action"

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
  # def current_task
  #   Task.find_by(id: session[:user])
  # end
  def following?(other_user)
    current_user.followings.include?(other_user)
  end
end

 get '/' do
  "IdeaMaker"
  erb :index
 end

 get '/signin' do
  erb :sign_in
 end

 get '/signup' do
  erb :sign_up
 end

 get '/home' do
  if current_user.nil?
    redirect '/signin'
  end

  erb :home
 end

get '/mypage' do
  if current_user.nil?
    @tasks = Task.none
  else
    @tasks = current_user.tasks
  end
  erb :mypage
end

post '/:id/delete' do
  tasks = Task.find(params[:id])
  tasks.delete
  redirect "/mypage"
end

 post '/signin' do
  # ログイン
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end

  redirect '/home'
 end

 post '/signup' do
  # 会員登録
  if User.find_by(mail: params[:mail]).nil?
  @user = User.create(mail:params[:mail], password:params[:password],password_confirmation:params[:password_confirmation])
  else
    redirect '/signup'
end

  if @user.persisted?
    session[:user] = @user.id
  end
  redirect '/home'
 end

 get '/signout' do
  # ログアウト
    session[:user] = nil
    redirect '/'
 end

 post '/tasks' do
  current_user.tasks.create(title: params[:title],question: params[:question])
  redirect '/mypage'
 end

 before '/tasks' do
  if current_user.nil?
    redirect '/home'
  end
 end

post '/tasks/:id/done' do
  task =Task.find(params[:id])
  task.completed = true
  task.save
  redirect '/mypage'
end

get '/timeline' do
  @tasks = Task.all

  erb :timeline
end

post '/comments/:id' do
  task = Task.find(params[:id])
  task.comments.create(answer:params[:answer],user_id:session[:user])
  redirect '/tasks/'+params[:id]+'/comments'
end

post '/tasks/:id/comments' do
 comment = Task.find(params[:id])
 comment.completed = true
 comment.save
 end

 get '/tasks/:id/comments' do
  @task_id = params[:id]

  erb :comments

 end

 get '/account/:id' do
  @account = User.find(params[:id])
  @account_id = params[:id]
  @tasks = Task.where(user_id: params[:id])
  @current_user = current_user
  @is_follow = following?(@account)
  erb :account

 end

 get '/account/:id/follows' do
  @account = User.find(params[:id])
  @follows = User.find(params[:id]).followings
   erb :follows
 end

 get '/account/:id/followers' do
  @account = User.find(params[:id])
  @followers = User.find(params[:id]).followers
   erb :followers
 end

 post '/account/:id/follows' do
  # @account = User.find(params[:id])
  @followers = User.find(params[:id]).followers
  redirect '/account/'+params[:id]+'/follows'
 end

 post '/account/:id/follow' do
  @account = User.find(params[:id])
  current_user.follow(@account)
  redirect '/account/'+params[:id]
 end

 post '/account/:id/unfollow' do
  @account = User.find(params[:id])
  current_user.unfollow(@account)
  redirect '/account/'+params[:id]
 end

 get '/search' do
  @keywords = params[:search]
  @question_hits = Task.where("question LIKE ?","%#{@keywords}%")
  @answer_hits = Comment.where("answer LIKE ?","%#{@keywords}%")
  @answer_hit = @answer_hits.map {|answer_hit| answer_hit.task}
  # @question_hits = keywords.map
  @hits = @question_hits | @answer_hit

  # @answer_hits = Task.find_by(id: @answer_user_id)
  # @hits = @hits,@answer_hits
  # @answer_hits = Task.find_by("answer LIKE ?","%#{@keywords}%").task
  erb :search
 end


# User.find_by(mail: params[:mail]).nil?