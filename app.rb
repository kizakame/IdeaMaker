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