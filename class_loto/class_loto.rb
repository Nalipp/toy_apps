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
  session[:classrooms] ||= []
end

def find_last_id(data)
  data.empty? ? 0 : data.last[:class_id].to_i
end

def select_classroom(id)
  classroom = session[:classrooms].find { |by_class| by_class[:class_id] == id.to_i }
  return classroom if classroom

  session[:error] = "That classroom is missing"
  redirect '/classrooms'
end

def invalid_length?(*data)
  data.any? { |value| !(1..100).cover?(value.length) }
end

get '/' do
  redirect '/classrooms'
end

get '/classrooms' do
  @classrooms = session[:classrooms]
  erb :classrooms
end

get '/classroom/new' do # form page to create a new classroom
  erb :new_classroom
end

post '/classroom/new' do  # post a new classroom
  @class_id = find_last_id(session[:classrooms]) + 1
  @classroom_name = params[:classroom_name]

  if invalid_length?(@classroom_name)
    session[:error] = "Data must be betweein 1 and 100 characters"
    erb :new_classroom
  else
    session[:classrooms] << { class_id: @class_id, classroom_name: @classroom_name }
    redirect '/classrooms'
  end
end

get '/classroom/:class_id' do  # display classroom by id
  @classroom = select_classroom(params[:class_id])
  erb :classroom
end

get '/classroom/:class_id/edit' do # form page to update an existing classroom
  @classroom = select_classroom(params[:class_id])
  erb :edit_classroom
end

post '/classroom/:class_id' do
  @classroom = select_classroom(params[:class_id])
  @classroom_name = params[:classroom_name]

  if invalid_length?(@classroom_name)
    session[:error] = "Data must be betweein 1 and 100 characters"
    erb :edit_classroom
  else
    @classroom[:classroom_name] = params[:classroom_name]
    redirect '/classrooms'
  end
end

post '/classroom/:class_id/destroy' do
  @classroom = select_classroom(params[:class_id])
  session[:classrooms].reject! { |classroom| classroom == @classroom }

  redirect '/classrooms'
end
