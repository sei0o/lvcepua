require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'active_record'
require 'yaml'
require 'date'
require 'json'
require 'bcrypt'
require 'erb'
require 'securerandom'
require 'omniauth-twitter'
Dir["models/*"].each { |f| require_relative f }

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]

class MilkDriveApp < Sinatra::Base
  @@config = YAML.load ERB.new(File.read("config.yml")).result

  configure do
    register Sinatra::Reloader
    register Sinatra::Flash

    use Rack::Session::Cookie, :key => 'rack.session', :secret => @@config["session_secret"]
    use OmniAuth::Builder do
      provider :twitter, @@config["twitter_consumer_key"], @@config["twitter_consumer_secret"]
    end
    OmniAuth.config.full_host = "http://localhost:9299"
  end

  # configure :development do
  #   disable :show_exceptions
  # end

  helpers do
    def login?
      !!session[:user_name]
    end

    def login_user
      login? ? User.find_by(name: session[:user_name])
             : nil
    end

    def user_only
      unless login?
        if block_given?
          yield
        else
          flash[:warning] = "先にログインしてください。"
          redirect "/signin"
        end
      end
    end
  end

  before do
    @_user = login_user
  end

  ## Twitterログイン
  get "/auth/twitter/callback" do
    req = request.env["omniauth.auth"]
    user = User.find_by twitter_uid: req["uid"]
    if user
      # ログイン
      session[:user_name] = user.name
      flash[:success] = "ログインしました。"
      redirect "/user/#{user.name}"
    else
      # 新規登録
      u = User.new(
        name: req["info"]["nickname"],
        twitter_uid: req["uid"]
      )
      if u.save
        flash[:success] = "登録しました。"
        session[:user_name] = u.name
        redirect "/user/#{u.name}"
      else
        flash[:danger] = u.errors.full_messages
        redirect "/"
      end
    end
  end

  get "/auth/failure" do
    flash[:danger] = params[:message]
    redirect "/"
  end

  get "/settings" do
    user_only
    slim :settings
  end

  post "/settings" do
    user_only
    
    if @_user.save
      session[:user_name] = @_user.name
      flash[:success] = "変更しました。"
      redirect "/user/#{@_user.name}"
    else
      flash[:warning] = "変更に失敗しました。"
      redirect back
    end
  end

  get "/user/*" do |user_name|
    @user = User.find_by name: user_name
    slim :user
  end

  get "/signout" do
    user_only
    session[:user_name] = nil

    flash[:success] = "ログアウトしました。"
    redirect "/"
  end

  get "/" do
    slim :index
  end

end
