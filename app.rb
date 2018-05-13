require 'sinatra/base'
require './lib/users.rb'
require 'sinatra/flash'
require './lib/peeps.rb'

class Chitter < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  get '/chitter' do
    @peeps = Peeps.all
    @current_user = session[:username]
    erb :index
  end

  get '/sign_up' do
    erb :sign_up
  end

  post '/sign_up' do
    name, username, email, password = params[:name], params[:username], params[:email], params[:password]
    if Users.create(name, username, email, password) == 'username error'
      flash[:username_error] = 'This username is already taken'
      redirect('/sign_up')
    elsif Users.create(name, username, email, password) == 'email error'
      flash[:email_error] = 'This email is already in use'
      redirect('/sign_up')
    else
      redirect('/user_added')
    end
  end

  get '/user_added' do
    erb :user_added
  end

  get '/sign_in' do
    erb :sign_in
  end

  post '/sign_in' do
    if Users.username_available?(params[:username]) == false
      session[:username], session[:password] = params[:username], params[:password]
      redirect '/chitter'
    else
      flash[:user_does_not_exist] = "This user doesn't exist"
      redirect('/sign_in')
    end
  end

  get '/new_peep' do
    erb :new_peep
  end

  post '/new_peep' do
    current_user = session[:username]
    peep_text = params[:text]
    time = Time.now.strftime('%I:%M%P')
    Peeps.peep(current_user, time, peep_text)
    redirect '/chitter'
  end

  run! if app_file == $0
end
