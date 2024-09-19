require 'rails_helper'

RSpec.describe "Partner index", type: :feature do
  before :each do
    partners = []

    partners += 10.times.map do |n|
      Partner.create! name: "Alpha partner", placecal_id: 100 + n
    end
    
    partners += 10.times.map do |n|
      Partner.create! name: "Beta partner", placecal_id: 200 + n
    end

    kw1 = Keyword.create! name: "Cappa keyword"
    kw2 = Keyword.create! name: "Delta keyword"

    5.times do |n|
      partners[n].keywords << kw1
    end

    15.times do |n|
      partners[n + 2].keywords << kw2
    end
  end

  it 'has filtering' do
    visit '/'

    # visit partners index, see all partners    
    click_link 'Partners'

    expect(page).to have_selector('article.partner', count: 20)
    expect(page).to have_selector('article.partner .keyword', count: 20)
    expect(page).not_to have_content('Reset filter')

    # enter name filter, only see matches for that name
    fill_in :name, with: 'Alpha'
    click_button 'Apply'

    expect(page).to have_selector('article.partner', count: 10)
    expect(page).to have_content('Reset filter')

    # clear filter, see all partners again
    click_link 'Reset filter'
    
    expect(page).to have_selector('article.partner', count: 20)

    # click on keyword, only see partners with keyword
    within "article.partner:nth-child(10)" do
      click_link "Delta keyword"
    end
    
    expect(page).to have_selector('article.partner', count: 15)
    expect(page).to have_content('Reset filter')

    # enter name filter, see partners with name and keyword
    fill_in :name, with: 'Beta'
    click_button 'Apply'

    expect(page).to have_selector('article.partner', count: 7)
    expect(page).to have_content('Reset filter')

    # FIXME: test having a name filter active and clicking on
    #   on keyword should keep the name filter param
  end
end
