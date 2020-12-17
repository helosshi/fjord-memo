CONNECTION = PG.connect(host: 'localhost', user: 'postgres', dbname: 'fjord_memo_db')
CONNECTION.internal_encoding = 'UTF-8'

def connection_to_db
  PG.connect(host: 'localhost', user: 'postgres', dbname: 'fjord_memo_db')
end