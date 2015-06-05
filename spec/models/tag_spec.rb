require 'spec_helper'
describe Tag do
  context '#create_tags' do
    context 'when tags are not present in database' do

      it 'should create tags for all given names' do
        tag_names = %w(one two three)
        Tag.create_tags(tag_names)
        expect(Tag.count).to eq 3
        expect(Tag.all.collect(&:name)).to match_array(['one', 'two', 'three'])
      end

      it 'should create tags unique names' do
        tag_names = %w(one two three One)
        Tag.create_tags(tag_names)

        expect(Tag.count).to eq 3
        expect(Tag.all.collect(&:name)).to match_array(['one', 'two', 'three'])
      end
    end
  end
end