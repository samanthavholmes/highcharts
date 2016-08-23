module ChartsHelper

  def get_check_totals_by_day(day_of_week)
    totals = {}
    half_hour_totals = []
    most_recent_half_hour_totals = []
    most_recent_totals = {}
    indexes_of_day = {sunday: 1, monday: 2, tuesday: 3, wednesday: 4, thursday: 5, friday: 6, saturday: 7}
    # index = indexes_of_day[day_of_week.downcase.to_sym]
    # date = Date.today.beginning_of_week(day)
    date = Date.new(2016, 7, 10)
    most_recent_date = {year: date.year, month: date.month, day: date.day}
    days = [date, date -= 7, date -= 7, date -= 7, date -= 7].map! {|date| date.strftime('%m%d')}
    hour = 17
    lower_min = 0
    higher_min = 29
    until hour == 23 && higher_min == 29
      $db.query(("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d') IN (#{days[0]}, #{days[1]}, #{days[2]}, #{days[3]}, #{days[4]}) AND HOUR(closed_at) = #{hour} AND MINUTE(closed_at) BETWEEN #{lower_min} AND #{higher_min}")).each do |total|
        half_hour_totals << total.values.first unless total.values.first == 0
      end
      $db.query(("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d') = #{days[0]} AND HOUR(closed_at) = #{hour} AND MINUTE(closed_at) BETWEEN #{lower_min} AND #{higher_min}")).each do |total|
        most_recent_half_hour_totals << total.values.first unless total.values.first == 0
      end
      utc_time = DateTime.new(most_recent_date[:year], most_recent_date[:month], most_recent_date[:day], hour, lower_min).to_i * 1000
      totals[utc_time] = half_hour_totals
      most_recent_totals[utc_time] = most_recent_half_hour_totals
      half_hour_totals = []
      most_recent_half_hour_totals = []
      hour += 1 if higher_min == 59
      if lower_min == 30
        lower_min = 0
        higher_min = 29
      else
        lower_min = 30
        higher_min = 59
      end
    end
    return {totals: totals, most_recent_totals: most_recent_totals}
  end

  def get_ranges_by_day(totals)
    totals = take_off_highest_lowest(totals)
    ten_percent_of_totals_length = totals.length * 1/10
    min = get_median(totals[0...ten_percent_of_totals_length], ten_percent_of_totals_length).round(2)
    max = get_median(totals[-ten_percent_of_totals_length..-1], ten_percent_of_totals_length).round(2)
    return [min, max]
  end

  def get_median(totals, ten_percent_of_totals_length)
    if totals.length.odd?
      return totals[ten_percent_of_totals_length/2]
    else
      return totals[(ten_percent_of_totals_length/2) -1.. ten_percent_of_totals_length/2].reduce(:+)/2
    end
  end

  def take_off_highest_lowest(totals)
    totals.map! {|total| total/100.00}
    totals.shift
    totals.pop
    return totals
  end

  def get_avg_by_day(totals)
    totals = take_off_highest_lowest(totals) unless totals.length <= 2
    return [(totals.reduce(:+)/totals.length).round(2)]
  end

  def get_ranges_for_week(totals)
    final_totals = []
    totals.each do |time, hour_totals|
      next if hour_totals.empty?
      hour_totals.sort!.uniq!
      final_totals << [time] + get_ranges_by_day(hour_totals)
    end
    return final_totals
  end

  def get_avg_for_most_recent(totals)
    final_totals = []
    totals.each do |time, hour_totals|
      next if hour_totals.length <= 1
      hour_totals.sort!.uniq!
      final_totals << [time] + get_avg_by_day(hour_totals)
    end
    return final_totals
  end

  def get_max_of_all_totals(ranges, most_recent_totals)
    all_totals = []
    ranges.each {|total| all_totals << total[2]}
    # most_recent_totals.each {|total| all_totals << total[1]}
    return all_totals.max
  end
end
