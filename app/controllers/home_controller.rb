class HomeController < ApplicationController

  def root
    hot_partners = Partner.order('random()').limit(10)

    hot_events = EventInstance
      .from_day_onward(Time.now)
      .order('random()')
      .limit(10)

    @hot_feed = (hot_events + hot_partners).shuffle

    @hot_keywords = Keyword
      .joins(:partner_keywords)
      .group(:partner_id)
      .having("count(partner_id) > 0")
      .order('random()')
      .limit(10)
  end

  def about
  end

end
