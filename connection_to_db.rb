def connection_to_db
  PG.connect(host: 'localhost', user: 'postgres', dbname: 'fjord_memo_db')
end
