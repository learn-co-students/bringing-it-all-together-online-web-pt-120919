require 'pry'

class Dog 
	attr_accessor :id, :name, :breed 

	def initialize(params)  
		params.each {|key, value| self.send(("#{key}="), value)} 
	end 

	def self.create_table 
		sql = %Q(
			CREATE TABLE dogs (
				id INTEGER PRIMARY KEY, 
				name TEXT, 
				breed TEXT
			) 
		) 
		DB[:conn].execute(sql)
	end 

	def self.drop_table 
		sql = %Q(
			DROP TABLE dogs 
		)
		DB[:conn].execute(sql)
	end  

	def self.create(dog_attributes)
		dog = Dog.new(dog_attributes) 
		dog.save 
		dog
	end 

	def save 
		sql = %Q(
			INSERT INTO dogs (name, breed) VALUES (?,?)
		) 
		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
		self
	end 

	def self.new_from_db(row)
		dog_attributes = {
			id: row[0], 
			name: row[1],
			breed: row[2]
		}
		dog = Dog.new(dog_attributes)
	end 

	def self.find_by_id(id) 
		sql = %Q(
			SELECT * FROM dogs WHERE id = ? LIMIT 1
		) 

		DB[:conn].execute(sql, id).map do |row| 
			self.new_from_db(row) 
		end.first
	end 

	def self.find_by_name(dog_name) 
		sql = %Q(
			SELECT * FROM dogs WHERE name = ?
		) 

		DB[:conn].execute(sql, dog_name).map do |dog| 
			self.new_from_db(dog) 
		end.first 
	end 

	def self.find_or_create_by(name:, breed:) 
		sql = %Q(
			SELECT * FROM dogs WHERE name = ? AND breed = ? 
		)
		dog = DB[:conn].execute(sql, name, breed).first
		if dog 
			new_dog = self.new_from_db(dog) 
		else 
			new_dog = self.create(name: name, breed: breed) 
		end 
		new_dog
	end 

	def update 
		sql = %Q(
		UPDATE dogs SET name = ?, breed = ? WHERE id = ?
		) 

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end 
end 