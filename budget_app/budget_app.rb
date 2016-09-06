require 'pry'

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  session[:categories] ||= []
end

helpers do
  def find_by(category)
    session[:categories].select { |ctg| ctg[:category_type] == category }
  end
end

get '/' do
  redirect '/categories'
end

def validate_invalid_length(*values)
  !values.select { |value| value.length > 100 }.empty?
end

def validate_empty_value(*values)
  !values.select { |value| value.length < 1 }.empty?
end

get '/categories' do
  erb :categories
end

get '/new_category/:category_type' do
  @category_type = params[:category_type]
  erb :new_category
end

post '/new_category/:category_type' do
  @date = params[:date]
  @amount = params[:amount]
  @description = params[:description]
  @category_type = params[:category_type]

  if validate_invalid_length(@date, @amount, @description)
    session[:error] = "Inputs must be less than 100 characters"
    erb :new_category
  elsif validate_empty_value(@amount)
    session[:error] = "Amount must not be empty"
    erb :new_category
  else
    session[:categories] << { date: @date, amount: @amount, description: @description, category_type: @category_type }
    redirect "/new_category/#{@category_type}"
  end
end
