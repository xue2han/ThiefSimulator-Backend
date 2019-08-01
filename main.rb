require 'sinatra'
require 'sqlite3'

# Open a SQLite 3 database file
db = SQLite3::Database.open 'data.db'

helpers do
    def json(data)
      JSON.dump(data)
    end
end

get '/rank/:category' do |category|

    if category == "money" or category == "children" or category == "jail"
        rs = db.query "SELECT * FROM #{category} ORDER BY value DESC LIMIT 100"
        list = []
        rs.each_hash do |a|
            list << a
        end
        return json :success => true,:result => list
    else
        return json :success => false,:msg => "unknown category : #{category}"
    end
end

post '/create_account' do

    body = JSON.parse request.body.read
    name = body['name']

    begin
        db.execute "INSERT INTO accounts (name) VALUES (?)" , name
        db.execute "INSERT INTO money (name,value) VALUES (?,?)" ,name,0
        db.execute "INSERT INTO children (name,value) VALUES (?,?)" ,name,0
        db.execute "INSERT INTO jail (name,value) VALUES (?,?)" ,name,0
        return json :success => true
    rescue SQLite3::Exception => e
        return json :success => false
    end
end

post '/upload/:category' do |category|
    body = JSON.parse request.body.read

    name = body['name']
    value = body['value']

    if category == "money" or category == "children" or category == "jail"
        rs = db.query "SELECT * FROM accounts where name = ?",name
        if rs.next 
            db.execute "UPDATE #{category} SET value=? WHERE name=?",value,name
        else
            return json :success => false,:msg => "unknown name : #{name}"
        end
    else
        return json :success => false,:msg => "unknown category : #{category}"
    end
end

get '/clear' do
    db.execute "DELETE FROM accounts"
    db.execute "DELETE FROM money"
    db.execute "DELETE FROM children"
    db.execute "DELETE FROM jail"
end