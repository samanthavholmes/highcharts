require 'net/ssh'
class ChartsController < ApplicationController
  include ChartsHelper

  def index
    totals_hash = get_check_totals_by_day("sunday")
    @ranges = get_ranges_for_week(totals_hash[:totals])
    @most_recent = get_avg_for_most_recent(totals_hash[:most_recent_totals])
    @max = get_max_of_all_totals(@ranges, @most_recent)
  end
end