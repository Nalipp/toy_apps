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

  def find_total(*category)
    total = []
    category.each do |category|
      total << find_by(category).map { |ctg| ctg[:amount].to_i }.inject(:+)
    end
    total.inject(:+)
  end
end

get '/' do
  redirect '/categories'
end

def validate_invalid_length(*values)
  !values.select { |value| value.length > 80 }.empty?
end

def validate_empty_value(*values)
  !values.select { |value| value.length < 1 }.empty?
end

def find_next_id(category)
  return 0 if find_by(category).empty?
  find_by(category).last[:id]
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
  @id = find_next_id(@category_type) + 1

  if validate_invalid_length(@date, @amount, @description)
    session[:error] = "Inputs must be less than 100 characters"
    erb :new_category
  elsif validate_empty_value(@amount)
    session[:error] = "Amount must not be empty"
    erb :new_category
  else
    session[:categories] << { id: @id, date: @date, amount: @amount, description: @description, category_type: @category_type }
    redirect "/new_category/#{@category_type}"
  end

  post '/new_category/:category_id' do

  end
end
