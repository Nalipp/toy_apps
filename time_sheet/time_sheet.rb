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
  session[:timesheets] ||= []
end

def get_last_id(data)
  data.empty? ? 0 : data.last[:timesheet_id].to_i
end

def invalid_length?(*data)
  data.any? { |input| !(1..100).cover?(input.length) }
end

def find_timesheet(id)
  timesheet = session[:timesheets].find { |timesheet| timesheet[:timesheet_id] == id.to_i }
  return timesheet if timesheet

  session[:error] = "That timesheet is missing"
  redirect '/timesheets'
end

get '/' do
  redirect '/timesheets'
end

get '/timesheets' do
  @timesheets = session[:timesheets]
  erb :timesheets
end

get '/timesheet/new' do
  erb :new_timesheet
end

post '/timesheet/new' do
  @timesheet_name = params[:timesheet_name]
  @timesheet_id = get_last_id(session[:timesheets]) + 1

  if invalid_length?(@timesheet_name)
    session[:error] = "Inputs must be between 1 and 100 characters"
    erb :new_timesheet
  else
    session[:timesheets] << { timesheet_id: @timesheet_id, timesheet_name: @timesheet_name }
    redirect "/timesheets"
  end
end

get '/timesheet/:timesheet_id' do
  @timesheet = find_timesheet(params[:timesheet_id])
  erb :timesheet
end

get '/timesheet/:timesheet_id/edit' do
  @timesheet = find_timesheet(params[:timesheet_id])
  erb :edit_timesheet
end

post '/timesheet/:timesheet_id/edit' do
  @timesheet = find_timesheet(params[:timesheet_id])
  @timesheet_name = params[:timesheet_name]

  if invalid_length?(@timesheet_name)
    session[:error] = "Inputs must be between 1 and 100 characters"
    erb :new_timesheet
  else
    @timesheet[:timesheet_name] = params[:timesheet_name]
    redirect "/timesheets"
  end
end

post '/timesheet/:timesheet_id/destroy' do
  @timesheet = find_timesheet(params[:timesheet_id])

  session[:timesheets].reject! { |timesheet| timesheet == @timesheet }
  redirect "/timesheets"
end
