require 'sinatra'
require 'sinatra/reloader'
require 'pg'

# global setting
enable :method_override

CONNECTION = PG.connect(host: 'localhost', user: 'postgres', dbname: 'fjord_memo_db')
CONNECTION.internal_encoding = 'UTF-8'

def load_db
  CONNECTION.exec('SELECT * FROM memos')
end

def reorder_db
  CONNECTION.exec('SELECT * FROM memos ORDER BY create_time')
end

def add_db
  CONNECTION.exec(
    'INSERT INTO memos(title,details,create_time,last_edit_time) values($1,$2,now(),now())',
    [params[:title], params[:details]]
  )
end

def chech_db
  CONNECTION.exec('SELECT * FROM memos WHERE id=$1', [params[:id]])
end

def update_db
  CONNECTION.exec('UPDATE memos SET title = $1,details = $2,last_edit_time = now() WHERE id = $3', [params[:title], params[:details], params[:id]])
end

def delete_db
  CONNECTION.exec('DELETE FROM memos WHERE id = $1', [params[:id]])
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
  @title = 'Memo'
  @content = "created by #{strong(@author)}"
  memo_list = ''
  reorder_db.each do |id|
    memo_list << "<li class=list-group-item}><a href=#{"/#{id['id']}"}>#{h(id['title'])}</a></li>"
  end
  @memo_list = memo_list
  erb :index
end

get '/about' do
  @title = 'about'
  @content = "about content by#{strong(@author)}"
  erb :about
end

get '/new' do
  erb :new
end

get '/edit/:id' do
  @id = params[:id].to_i
  chech_db.each do |hoge|
    @title = hoge['title']
    @details = hoge['details']
    @create_time = hoge['create_time']
    @last_edit_time = hoge['last_edit_time']
  end
  erb :edit
end

get '/:id' do
  @id = params[:id].to_i
  chech_db.each do |hoge|
    @title = hoge['title']
    @details = hoge['details']
    @create_time = hoge['create_time']
    @last_edit_time = hoge['last_edit_time']
  end
  erb :show
end

post '/save' do
  add_db
  @title = params[:title]
  @details = params[:details]
  erb :save
end

get '/update/:id' do
  @id = params[:id]
  @title = params[:title]
  @details = params[:details]
  @create_time = params[:create_time]
  update_db
  erb :update
end

get '/delete/:id' do
  @id = params[:id]
  delete_db
  erb :delete
end
