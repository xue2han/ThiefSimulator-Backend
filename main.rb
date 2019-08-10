require 'sinatra'
require 'sqlite3'

helpers do
    def json(data)
      JSON.dump(data)
    end
end

def getDB
    return SQLite3::Database.new 'data.db'
end

get '/rank/:category' do |category|
    username = params['name']

    if category == "money" or category == "children" or category == "jail"
        begin
            db = getDB
            rs = db.query "SELECT * FROM #{category} ORDER BY value DESC LIMIT 100"
            list = []
            rs.each_hash do |a|
                list << a
            end

            if username
                rs = db.query "SELECT rownum,value FROM ( SELECT ROW_NUMBER () OVER ( ORDER BY value DESC ) rownum,name,value FROM #{category} ) t WHERE name=?",username
                myRank = rs.next_hash
                if myRank
                    myRank = {:value => myRank["value"],:rank => myRank["rownum"]}
                    return json :success => true,:rankList => list,:myRank => myRank
                end
            end
            return json :success => true,:rankList => list
        ensure
            rs.close if rs
            db.close if db
        end
    else
        return json :success => false,:msg => "unknown category : #{category}"
    end
end

post '/create_account' do
    db = getDB
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
    ensure
        db.close if db
    end
end

post '/upload/:category' do |category|
    body = JSON.parse request.body.read

    name = body['name']
    value = body['value']

    if category == "money" or category == "children" or category == "jail"
        begin
            db = getDB
            rs = db.query "SELECT * FROM accounts where name = ?",name
            if rs.next 
                db.execute "UPDATE #{category} SET value=? WHERE name=? AND value < ?",value,name,value
                return json :success => true
            else
                return json :success => false,:msg => "unknown name : #{name}"
            end
        ensure
            rs.close if rs
            db.close if db
        end
    else
        return json :success => false,:msg => "unknown category : #{category}"
    end
end

get '/clear' do
    #db.execute "DELETE FROM accounts"
    #db.execute "DELETE FROM money"
    #db.execute "DELETE FROM children"
    #db.execute "DELETE FROM jail"
end