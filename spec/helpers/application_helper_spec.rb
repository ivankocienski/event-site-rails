require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context 'fancy_time_period_format' do
    it 'gives correct text for a given input' do
      times = [
        { hour:  0, minute:  0, text: "zero minutes" },
        { hour: 23, minute: 59, text: 'all day' },
        { hour:  0, minute: 15, text: '15 minutes' },
        { hour:  0, minute: 30, text: 'half an hour' },
        { hour:  1, minute:  0, text: 'an hour' },
        { hour:  2, minute:  0, text: '2 hours' },
        { hour:  3, minute: 30, text: '3 and a half hours' },
        { hour:  4, minute: 45, text: '4 hours and 45 minutes' }
      ]

      times.each do |check|
        starts_at = Time.new(2000, 1, 1, 0, 0, 0)
        ends_at = Time.new(2000, 1, 1, check[:hour], check[:minute], 0)

        out = fancy_time_period_format(starts_at, ends_at)
        expect(out).to eq check[:text]
      end
    end
  end
end
