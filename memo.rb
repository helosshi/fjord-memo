require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require './connection_to_db'

# global setting
enable :method_override

def reorder_memo
  connection_to_db
  @results = CONNECTION.exec('SELECT * FROM memos ORDER BY create_time')
end

def add_memo
  CONNECTION.exec(
    'INSERT INTO memos(title,details,create_time,last_edit_time) values($1,$2,now(),now())',
    [@title, @details]
  )
end

def check_memo
  CONNECTION.exec('SELECT * FROM memos WHERE id=$1', [@id])
end

def update_memo
  CONNECTION.exec('UPDATE memos SET title = $1,details = $2,last_edit_time = now() WHERE id = $3', [@title, @details, @id])
end

def delete_memo
  CONNECTION.exec('DELETE FROM memos WHERE id = $1', [@id])
end

# helpers
before do
  @author = 'helosshi'
end

helpers do
  def strong(abc)
    "<strong> #{abc} </strong>"
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# routing
get '/' do
  @page_name = 'Memo'
  @content = "created by #{strong(@author)}"
  memo_list = ''
  reorder_memo
  results = @results
  results.each do |result|
    memo_list << "<li class=list-group-item}><a href=#{"/#{result['id']}"}>#{h(result['title'])}</a></li>"
  end
  @memo_list = memo_list
  CONNECTION.finish
  erb :index
end

get '/about' do
  @page_name = 'about'
  @content = "about content by#{strong(@author)}"
  erb :about
end

get '/new' do
  erb :new
end

get '/edit/:id' do
  @id = params[:id].to_i
  check_memo.each do |hoge|
    @title = hoge['title']
    @details = hoge['details']
    @create_time = hoge['create_time']
    @last_edit_time = hoge['last_edit_time']
  end
  @page_name = @title
  erb :edit
end

get '/:id' do
  @id = params[:id].to_i
  check_memo.each do |hoge|
    @title = hoge['title']
    @details = hoge['details']
    @create_time = hoge['create_time']
    @last_edit_time = hoge['last_edit_time']
  end
  @page_name = @title
  erb :show
end

post '/save' do
  @title = params[:title]
  @details = params[:details]
  @page_name = 'saved'
  add_memo
  erb :save
end

get '/update/:id' do
  @id = params[:id]
  @title = params[:title]
  @details = params[:details]
  @create_time = params[:create_time]
  @page_name = 'updated'
  update_memo
  erb :update
end

get '/delete/:id' do
  @id = params[:id]
  @page_name = 'deleted'
  delete_memo
  erb :delete
end
