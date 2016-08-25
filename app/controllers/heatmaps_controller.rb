class HeatmapsController < ApplicationController
  include ChartsHelper
  def index
    if !params[:byday] || params[:byweek]
      @day_totals = get_totals_by_half_hour(Date.today, "1330", "2230", "employee_day")
      @week_totals = get_totals_for_week_by_day(Date.today, "1330", "2230", "employee_week")
      binding.pry
    end
  end
end
