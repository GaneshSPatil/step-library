class Tag < ActiveRecord::Base

  def self.create_tags(tags)
    tags.map{|tag|
      Tag.find_or_create_by(name: tag.downcase)
    }
  end
end
