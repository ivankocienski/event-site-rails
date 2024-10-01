require 'rails_helper'

RSpec.describe "Partner index", type: :feature do
  def given_some_partners_exist
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
    given_some_partners_exist

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

  it 'has locations' do
    geo_1 = GeoEnclosure.create!(
      name: 'Alpha Ward',
      ons_id: 'X000',
      ons_version: 202020,
      ons_type: 'ward'
    )
    geo_2 = GeoEnclosure.create!(
      name: 'Beta Ward',
      ons_id: 'X001',
      ons_version: 202020,
      ons_type: 'ward'
    )

    partner_1 = Partner.build(
      name: 'Gamma Partner',
      placecal_id: 300
    )
    partner_1.address_ward = geo_1
    partner_1.save!

    partner_2 = Partner.build(
      name: 'Epsilon Partner',
      placecal_id: 400
    )
    partner_2.address_ward = geo_2
    partner_2.save!

    visit '/'
    click_link 'Partners'

    expect(page).to have_selector('article.partner', count: 2)

    click_link 'Alpha Ward'
    expect(page).to have_selector('h2', text: 'Filtering in area Alpha Ward')
    expect(page).to have_selector('article.partner', count: 1)
  end
end
