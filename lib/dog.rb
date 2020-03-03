class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
      self
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    end
  end

  # Method is called once instance attributes (name or breed) are updated
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  # Takes a row of data from dogs database and creates dog instance from data
  def self.new_from_db(db_row)
    new_dog = self.new(name: db_row[1], breed: db_row[2], id: db_row[0])
    new_dog
  end

  # Finds dog from dogs database and creates dog instance from data
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    dog_from_db = DB[:conn].execute(sql, id).flatten
    self.new_from_db(dog_from_db)
  end

  # Finds dog from dogs database and creates dog instance from data
  # If dog isn't found in databse, one is created and saved to database
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog_from_db = DB[:conn].execute(sql, name, breed).flatten
    if dog_from_db.empty?
      self.create(name: name, breed: breed)
    else
      self.new_from_db(dog_from_db)
    end
  end

  # Finds dog from dogs database using name creates dog instance from data
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end
end
