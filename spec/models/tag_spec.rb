require 'spec_helper'
describe Tag do
  context '#create_tags' do
    context 'when tags are not present in database' do

      it 'should create tags for all given names' do
        tag_names = %w(one two three)
        tags = Tag.create_tags(tag_names)
        expect(tags.count).to eq 3
        expect(tags.map(&:name)).to eq tag_names
      end

      it 'should create tags unique names' do
        tag_names = %w(one two three One)
        tags = Tag.create_tags(tag_names)

        expect(tags.map(&:name)).to eq %w(one two three)
      end
    end

    context 'when tags are present in database' do

      before do
        tag_names = %w(one two)
        Tag.create_tags(tag_names)
      end

      it 'should create tags for only new given names' do
        tag_names = %w(one two three)
        Tag.create_tags(tag_names)

        expect(Tag.all.count).to eq 3
        expect(Tag.all.map(&:name)).to eq tag_names
      end
    end
  end
end