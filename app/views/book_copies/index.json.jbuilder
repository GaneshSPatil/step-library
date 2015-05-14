json.array!(@book_copies) do |book_copy|
  json.extract! book_copy, :id, :isbn, :book_id
  json.url book_copy_url(book_copy, format: :json)
end
