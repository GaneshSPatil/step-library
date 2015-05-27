# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

book1 = Book.create(isbn:"1937785564", title:"Agile Web Development with Rails 4", author:"David Hansson")
book2 = Book.create(isbn:"9788185986173", title:"Malgudi Days", author:"R. K. Narayan")
book3 = Book.create(isbn:"9780143414988", title:"The Guide: a novel", author:"R. K. Narayan")
book4 = Book.create(isbn:"9788185986029", title:"The Dark Room", author:"R. K. Narayan")

BookCopy.create(isbn:book1.isbn, status:"Available", book_id:book1.id, copy_id: 1)
BookCopy.create(isbn:book2.isbn, status:"Available", book_id:book2.id, copy_id: 1)
BookCopy.create(isbn:book3.isbn, status:"Available", book_id:book3.id, copy_id: 1)
BookCopy.create(isbn:book4.isbn, status:"Available", book_id:book4.id, copy_id: 1)
