require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'

require "sinatra/activerecord"
require "open-uri"
require "json"
require "net/http"
require 'dotenv/load'

enable :sessions

helpers do
    def  current_user
        User.find_by(id: session[:user])
    end
    
    def current_group
        Group.find_by(id: session[:group])
    end
    
    def current_chat
        Chat.find_by(id: session[:chat])
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV["CLOUD_NAME"]
        config.api_key = ENV["CLOUDINARY_API_KEY"]
        config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    end
end

before "/invite" do
    @members = Member.all
    @nowgroup = Group.find_by(id: session[:group])
end

get "/" do
    @user = current_user
    erb :index
end


post "/signup" do
    img=params[:image]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload["url"]
    
    User.create(
        name: params[:name],
        image: img_url,
        mentor: params[:mentor],
        password: params[:password], 
        password_confirmation: params[:password_confirmation]
    )
    
    redirect "/"
end

get "/signup" do
    erb :sign_up
end

post "/signin" do
    @user=User.find_by(name: params[:name])
    if @user && @user.authenticate(params[:password])
        session[:user] = @user.id
        redirect "/list"
    else
        redirect "/"
    end
end

get "/signout" do
    session[:user] = nil
    redirect "/"
end


get "/home" do
    erb :home
end

get "/group" do
    erb :group
end

get "/invite" do
    @keyward_users=[]
    @users=User.all
    @users.each do |user|
        if user.name == params[:keyward]
            @keyward_users.push(user.name)
        end
    end
    erb :invite
end

post "/create_group" do
    @group = Group.create(
        name: params[:name]
    )
    Member.create(
        user_id: current_user.id,
        group_id: @group.id
    )
    session[:group] = @group.id
    redirect "/invite"
end

post "/invite" do
    @member = Member.create(
        user_id: params[:user_id],
        group_id: params[:group_id]
    )
    redirect "/invite"
end

get "/list" do
    @nowuser = current_user
    @nowuser_group = Member.find_by(user_id: @nowuser.id)
    @users = User.all
    @current_group = current_group
    @members =Member.all
    erb :list
end

get "/chat" do
    if !params[:group_id].nil?
        @group = Group.find_by(id: params[:group_id])
        
    else
        @group = Group.find_by(id: current_group.id)
    end
    @current_user = current_user
    session[:group] = @group
    @members = Member.all
    @group_name = current_group.name
    @chats = Chat.all
    @tasks = Task.all
    erb :chat
end

post "/chat" do
    @chat = Chat.create(
        user_id: params[:user_id],
        comment: params[:comment],
        group_id: params[:group_id],
        image: params[:image]
    )
    @group = params[:group_id]
    session[:chat] = @chat
    
    redirect "/chat"
end

post "/task" do
    Task.create(
        user_id: params[:user_id],
        todo: params[:todo],
        due_date: params[:due_date],
        done: params[:done]
    )
    
    
    
    redirect "/chat"
end

post "/task/:id/done" do
    task = Task.find(params[:id])
    task.done =! task.done
    task.save
    redirect "/chat"
end