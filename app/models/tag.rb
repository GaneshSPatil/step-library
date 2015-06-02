class Tag < ActiveRecord::Base

  def self.create_tags(tags_string)
    tags_string_downcase = tags_string.map(&:downcase)
    tags = tags_string_downcase.map do |tag_string|
      tag = Tag.where({:name => tag_string}).first
      if tag.nil?
        tag = self.create_tag(tag_string)
      end
      tag
    end
    tags.uniq
  end

  private
  def self.create_tag(tag_string)
    Tag.create({:name => tag_string})
  end

end
