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
  File.open("json/test.json", 'w') do |file|
    JSON.dump($json_data, file)
  end
end

# helpers
before do
  @author = "helosshi"
end

helpers do
  def  strong(a)
    "<strong> #{a} </strong>"
  end
end

# routing
get "/" do 
  @title = "Memo"
  @content = "index by" + strong(@author)
  if $memos.length != 0
    memo_list = ""
    $memos.each_with_index do |num,memo_index|
      memo_list << "<li><a href=#{"http://localhost:4567/show_memo?id=#{memo_index}"}>#{num["id"].to_s}_#{num["title"].to_s}</a></li>"
    end
    @memo_list = memo_list
  else
    @memo_list ="not_found"
  end
  erb :index
end

get "/about" do 
  @title = "about"
  @content = "about content by"+ strong(@author)
  erb :about
end

get "/new_memo" do
  if $memos.length != 0
    @id = $memos[-1]["id"].to_i + 1
  else
    @id = 0
  end
  erb :new_memo
end

get "/edit_memo" do
  @memo_index = params[:id].to_i
  @id = $memos[@memo_index]["id"]
  @title = $memos[@memo_index]["title"]
  @details = $memos[@memo_index]["details"]
  erb :edit_memo
end

get "/show_memo" do
  @memo_index = params[:id].to_i
  @id = $memos[@memo_index]["id"]
  @title = $memos[@memo_index]["title"]
  @details = $memos[@memo_index]["details"]
  erb :show_memo
end

post "/save_memo" do
  if $memos.length != 0
    @id = $memos[-1]["id"].to_i + 1
  else
    @id = 0
  end
  @title = params[:title]
  @details = params[:details]
  # saveの作業
  memo_new ={"id"=>@id.to_i, "title" => params[:title], "details" => params[:details]}
  $memos.push(memo_new)
  $memos.sort_by!{ |k| k["id"]}
  rewrite_json
  # 単に表示
  erb :save_memo
end

get "/update_memo" do
  @id = params[:id]
  @title = params[:title]
  @details = params[:details]
  # updateの作業
  hoge = $memos.index([:id]== 5).to_i
  p hoge
  $memos.delete_at(hoge)
  memo_new ={"id"=>@id.to_i, "title" => @title, "details" => @details}
  $memos.push(memo_new)
  $memos.sort_by!{ |k| k["id"]}
  rewrite_json
  #　単に表示
  erb :update_memo
end

get "/delete_memo" do
  # delete作業させる
  @id = params[:id]
  $memos.delete_at(@id.to_i)
  $memos.sort_by!{ |k| k["id"]}
  rewrite_json
  # 単に削除
  erb :delete_memo
end
