require 'sinatra'
require 'sinatra/reloader'
require 'json'

# global setting
enable :method_override

$json_file_path = 'json/test.json'

$json_data = open($json_file_path) do |io|
  JSON.load(io)
end

$memos = $json_data['memos']

def rewrite_json
  $memos.sort_by! { |k| k['create_time'] }
  File.open('json/test.json', 'w') do |file|
    JSON.dump($json_data, file)
  end
end

def get_timestamp
  @time_stamp = Time.now.to_i
end

def save_memo
  memo_new = { 'id' => @id.to_i, 'title' => params[:title], 'details' => params[:details], 'create_time' => @create_time, 'last_edit_time' => @last_edit_time }
  $memos.push(memo_new)
end

# helpers
before do
  @author = 'helosshi'
end

helpers do
  def strong(abc)
    "<strong> #{abc} </strong>"
  end
end

# routing
get '/' do
  @title = 'Memo'
  @content = "created by #{strong(@author)}"
  if !$memos.empty?
    memo_list = ''
    $memos.each_with_index do |num, memo_index|
      memo_list << "<li class=#{"list-group-item"}><a href=#{"http://localhost:4567/show_memo?memo_index=#{memo_index}"}>#{num['title']}</a></li>"
    end
    @memo_list = memo_list
  else
    @memo_list = 'not_found'
  end
  erb :index
end

get '/about' do
  @title = 'about'
  @content = "about content by#{strong(@author)}"
  erb :about
end

get '/new_memo' do
  @id = rand(1_000_000)
  erb :new_memo
end

get '/edit_memo' do
  @memo_index = params[:memo_index].to_i
  @id = $memos[@memo_index]['id']
  @title = $memos[@memo_index]['title']
  @details = $memos[@memo_index]['details']
  erb :edit_memo
end

get '/show_memo' do
  @memo_index = params[:memo_index].to_i
  @id = $memos[@memo_index]['id']
  @title = $memos[@memo_index]['title']
  @details = $memos[@memo_index]['details']
  erb :show_memo
end

post '/save_memo' do
  @id = if @id != 0
          params[:id]
        else
          rand(1_000_000)
        end
  @title = params[:title]
  @details = params[:details]
  get_timestamp
  @create_time = @time_stamp
  @last_edit_time = @time_stamp
  save_memo
  rewrite_json
  erb :save_memo
end

get '/update_memo' do
  @id = params[:id]
  @title = params[:title]
  @details = params[:details]
  @memo_index = params[:memo_index].to_i
  get_timestamp
  @create_time = $memos[@memo_index]['create_time']
  @last_edit_time = @time_stamp
  $memos.delete_at(@memo_index)
  save_memo
  rewrite_json
  erb :update_memo
end

get '/delete_memo' do
  @memo_index = params[:memo_index].to_i
  $memos.delete_at(@memo_index)
  rewrite_json
  erb :delete_memo
end
