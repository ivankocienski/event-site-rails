class AddMarkdownHtmlFieldsToPartnersAndEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :partners, :description_html, :text
    add_column :events, :description_html, :text
  end
end
