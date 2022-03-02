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

before do
    def  current_user
        User.find_by(id: session[:user])
    end
    
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV["CLOUD_NAME"]
        config.api_key = ENV["CLOUDINARY_API_KEY"]
        config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    end
end

get "/" do
    @user = current_user.name
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
        redirect "/"
    else
        redirect "/"
    end
end