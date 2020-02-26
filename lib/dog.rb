class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end
  
 def self.create_table
  DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )")
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (?,?)", name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
 def self.new_from_db(row)
    new_dog = create(name:row[1],breed:row[2])
    new_dog.id = row[0]
    new_dog
  end
  
  def self.find_by_id(id)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    new_dog = create(name:result[1],breed:result[2])
    new_dog.id = result[0]
    new_dog
  end
  
  def self.find_or_create_by(name:name,breed:breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1",name,breed)
    if !dog.empty?
      dog = dog[0]
      new_dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
    else
      new_dog = self.create(name:name,breed:breed)
    end
      new_dog
  end
  
  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    new_dog = create(name:result[1],breed:result[2])
    new_dog.id = result[0]
    new_dog
  end
  
 def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ?  WHERE id = ?", name, breed, id)
  end
end