require 'pry'
class Dog
  attr_accessor :name, :breed, :id
  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)} #????
    self.id ||= nil
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes_hash)
      dog = Dog.new(attributes_hash)
      dog.save
      dog
  end

  def self.new_from_db(row)
    attributes_hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    Dog.new(attributes_hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    DB[:conn].execute(sql,id).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if dog
      return_dog = self.new_from_db(dog)
    else
      return_dog = self.create({:name => name, :breed => breed})
    end
    return_dog
    #binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql,name).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
