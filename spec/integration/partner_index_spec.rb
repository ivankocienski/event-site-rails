require 'rails_helper'

RSpec.describe "Partner index", type: :feature do
  include Factories

  it 'shows list of partners' do
    given_some_partners_exist

    visit '/'
    click_link 'Partners'

    expect(page).to have_selector('article.partner', count: 10)
  end
end
