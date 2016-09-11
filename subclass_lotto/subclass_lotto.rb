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

def invalid_length?(max_length=100, *data)
  data.any? { |value| !(1..max_length).cover?(value.length) }
end

get '/' do
  redirect '/classrooms'
end

get '/classrooms' do
  @classrooms = session[:classrooms]
  erb :classrooms
end

get '/classroom/new' do # create a new classroom form page
  erb :new_classroom
end

post '/classroom/new' do  # post a new classroom
  @class_id = find_last_id(session[:classrooms]) + 1
  @classroom_name = params[:classroom_name]
  @student_names = params[:student_names].split("\r\n").each_with_index.map { |name, idx| [idx + 1, name, 2] }

  if invalid_length?(@classroom_name)
    session[:error] = "Classroom name must be betweein 1 and 100 characters"
    erb :new_classroom
  elsif invalid_length?(1000, @student_names)
    session[:error] = "Student names must be betweein 1 and 1000 characters"
    erb :new_classroom
  else
    session[:classrooms] << { class_id: @class_id, classroom_name: @classroom_name, student_names_col1: [], student_names_col2: @student_names, student_names_col3: [] }
    redirect "/classrooms"
  end
end

get '/classroom/:class_id' do  # display classroom by id
  @classroom = select_classroom(params[:class_id])

  erb :classroom
end

get '/classroom/:class_id/edit' do # update an existing classroom form page
  @classroom = select_classroom(params[:class_id])
  @classroom_name = @classroom[:classroom_name]
  erb :edit_classroom
end

post '/classroom/:class_id' do # update a classroom
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

post '/classroom/:class_id/destroy' do # destroy a classrrom
  @classroom = select_classroom(params[:class_id])
  session[:classrooms].reject! { |classroom| classroom == @classroom }

  redirect '/classrooms'
end

def select_student(student_id, class_id)
  classroom = select_classroom(class_id)
  classroom[:student_names_col2].select { |student| student[0] == student_id.to_i }
end

post '/classroom/:class_id/move_name' do
  binding.pry
  student_id = params[:move_name]

  select_student(student_id, params[:class_id])

end
