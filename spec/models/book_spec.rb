require 'spec_helper'

describe Book do
  context '#search' do
    it 'should give empty array when no book present with title having search parameter' do
      FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      expect(Book.search('the')).to eq([])
    end

    it 'should give book with title having search parameter' do
      book1 = FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming')
      expect(Book.search('programming')).to match_array([book2,book3])
    end
  end

  context '#order_by_title' do
    it 'should give book with title in ascending order' do

      book1 = FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming')

      expect(Book.order_by('title')).to eq([book2,book1,book3])
    end
  end
end