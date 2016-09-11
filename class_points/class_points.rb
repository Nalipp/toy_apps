require 'pry'

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'json'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

def data_path(filename="classroom_data.json")
  root_path = File.expand_path("../data", __FILE__)
  file_path = File.join(root_path, filename)
end

def load_classrooms_data
  data_path
  JSON.parse(file_path)
end

def write_to_json(data)
  File.open(data_path,"a"){ |file| file.puts data.to_json }
end

def read_json(filename="classroom_data.json")
  data = File.read(data_path("#{filename}"))
  JSON.parse(data)
end

def find_next_id
  load_classrooms
end

get '/' do
  redirect '/classrooms'
end

get '/classrooms' do
  @all_classrooms = read_json
  erb :classrooms
end

get '/classroom/new' do
  erb :new_classroom
end

post '/classroom/new' do
  classroom_id = 1
  @classroom_name = params[:classroom_name]
  @student_names = params[:student_names].split("\r\n")

  classroom_data = read_json
  classroom_data["#{classroom_id}"] = { classroom_name: @classroom_name, student_names: @student_names }
  write_to_json(classroom_data)

  redirect '/'
end
