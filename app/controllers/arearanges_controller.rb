require 'net/ssh'
class ArearangesController < ApplicationController
  include ChartsHelper

  def index
    if !params[:byday] && !params[:byweek]
      week_totals = get_totals_for_week_by_day(Date.today, "1330", "2230" , "week_area")
      day_totals = get_totals_for_week_by_day(Date.today, "1330", "2230" , "day_area")
      @timeframe = "Week"
    elsif (!params[:day] || !params[:start] || !params[:end] || params[:end].to_i <= params[:start].to_i)
      @error = "Please pick a valid day, start time, and end time"
    elsif params[:byweek]
      totals_hash = get_totals_for_week_by_day(params[:day], params[:start], params[:end])
      @ranges = get_ranges_for_month(totals_hash[:totals])
      @most_recent = get_avg(totals_hash[:most_recent_totals])
      @averages = get_avg(totals_hash[:totals])
      @timeframe = "Week"
    else
      week_totals = get_totals_by_half_hour(params[:day], params[:start],params[:end], "week_area")
      most_recent_totals = get_totals_by_half_hour(params[:day], params[:start] , params[:end], "day_area")
      @timeframe = params[:day].to_date.strftime("%A")
    end
    @ranges = get_ranges_for_month(week_totals)
    @most_recent = get_avg(week_totals)
    @averages = get_avg(most_recent_totals)
    @max = get_max_of_all_totals(@ranges, @most_recent)
  end

end