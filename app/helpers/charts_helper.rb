module ChartsHelper

  def get_totals_by_half_hour(day, start_time, end_time, type)
    # date = day.to_date
    date = Date.new(2016, 7, 10)
    date_hash = {year: date.year, month: date.month, day: date.day}
    days = [date, date -= 7, date -= 7, date -= 7, date -= 7].map! {|date| date.strftime('%m%d%y')}
    day_totals = {}
    day_half_hour_totals = []
    week_totals = {}
    week_half_hour_totals = []
    employee_day_totals = {}
    employee_day_half_hour_totals = []
    hour = start_time[0..1].to_i
    lower_min = start_time[2..3].to_i
    lower_min == 00 ? higher_min = 29 : higher_min = 59
    until hour == end_time[0..1].to_i && lower_min == end_time[2..3].to_i
      utc_time = DateTime.new(date_hash[:year], date_hash[:month], date_hash[:day], hour, lower_min).to_i * 1000
      if type == "week_area"
        $db.query("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') IN (#{days[1]}, #{days[2]}, #{days[3]}, #{days[4]}) AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{hour}#{lower_min} AND #{hour}#{higher_min}").each do |total|
          week_half_hour_totals << total.values.first unless total.values.first == 0
        end
        week_totals[utc_time] = week_half_hour_totals
        week_half_hour_totals = []
      elsif type == "day_area"
        $db.query("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') = #{days[0]} AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{hour}#{lower_min} AND #{hour}#{higher_min}").each do |total|
            day_half_hour_totals << total.values.first unless total.values.first == 0
        end
        day_totals[utc_time] = day_half_hour_totals
        day_half_hour_totals = []
      elsif type == "employee_day"
        $db.query("SELECT employee_id, total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') IN (#{days[1]}, #{days[2]}, #{days[3]}, #{days[4]}) AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{hour}#{lower_min} AND #{hour}#{higher_min} GROUP BY employee_id").each do |total|
          employee_day_half_hour_totals << {"#{total.values[0]}": total.values[1]} unless total.values[1] == 0
        end
        employee_day_totals[utc_time] = employee_day_half_hour_totals
        employee_day_half_hour_totals = []
      # elsif type == "employee_day"
      #   $db.query("SELECT employee_id, total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') = #{days[0]} AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{hour}#{lower_min} AND #{hour}#{higher_min} GROUP BY employee_id").each do |total|
      #       employee_day_half_hour_totals << {"#{total.values[0]}": total.values[1]} unless total.values[1] == 0
      #   end
      #   employee_day_totals[utc_time] = employee_day_half_hour_totals
      #   employee_day_half_hour_totals = []
      end
      if lower_min == 30
        lower_min = 0
        higher_min = 29
        hour += 1
      else
        lower_min = 30
        higher_min = 59
      end
    end
    return week_totals if type == "week_area"
    return day_totals if type == "day_area"
    # return employee_week_totals if type == "employee_week"
    return employee_day_totals if type == "employee_day"
  end

  def get_totals_for_week_by_day(start_date, start_time, end_time, type)
    week_totals = {}
    week_day_totals = []
    day_totals = {}
    each_day_totals = []
    date = Date.new(2016, 6, 19)
    employee_week_totals = {}
    employee_week_half_hour_totals = []
    # date = start_date.to_date
    lower_hour = start_time[0..1].to_i
    lower_min = start_time[2..3].to_i
    higher_hour = end_time[0..1].to_i
    higher_min = end_time[2..3].to_i
    most_recent_week = {first_day: date, second_day: date += 1, third_day: date +=1, fourth_day: date += 1, fifth_day: date += 1, sixth_day: date += 1, seventh_day: date += 1}
    weekdays = {}
    most_recent_week.each {|day, date| weekdays[day] = [date, date -= 7, date -= 7, date -=7, date -=7].map! {|d| d.strftime('%m%d%y')}}
    weekdays.each do |day, dates|
      utc_time = DateTime.new(("20" + dates[0][4..-1]).to_i, dates[0][0..1].to_i, dates[0][2..3].to_i).to_i * 1000
      if type == "week_area"
        $db.query("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') IN (#{dates[1]}, #{dates[2]}, #{dates[3]}, #{dates[4]}) AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{lower_hour}#{lower_min} AND #{higher_hour}#{higher_min}").each do |total|
          week_day_totals << total.values.first unless total.values.first == 0
        end
        week_totals[utc_time] = week_day_totals
        week_day_totals = []
      elsif type == "day_area"
        $db.query("SELECT total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') = #{dates[0]} AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{lower_hour}#{lower_min} AND #{higher_hour}#{higher_min}").each do |total|
          each_day_totals << total.values.first unless total.values.first == 0
        end
        day_totals[utc_time] = each_day_totals
        each_day_totals = []
      elsif type == "employee_week"
        $db.query("SELECT employee_id, total FROM ticket WHERE DATE_FORMAT(closed_at, '%m%d%y') = #{dates[0]} AND TIME_FORMAT(closed_at, '%H%i') BETWEEN #{lower_hour}#{lower_min} AND #{higher_hour}#{higher_min} GROUP BY employee_id").each do |total|
            employee_week_half_hour_totals << {"#{total.values[0]}": total.values[1]} unless total.values[1] == 0
        end
        employee_week_totals[utc_time] = employee_week_half_hour_totals
        employee_week_half_hour_totals = []
      end
    end
    return week_totals if type == "week_area"
    return day_totals if type == "day_area"
    return employee_week_totals if type == "employee_week"
  end

  def get_ranges_by_day(totals)
    totals = take_off_highest_lowest(totals)
    ten_percent_of_totals_length = totals.length * 1/10
    ten_percent_of_totals_length = 1 if ten_percent_of_totals_length == 0
    min = get_median(totals[0...ten_percent_of_totals_length], ten_percent_of_totals_length).round(2)
    max = get_median(totals[-ten_percent_of_totals_length..-1], ten_percent_of_totals_length).round(2)
    return [min, max]
  end

  def get_median(totals, ten_percent_of_totals_length)
    if totals.length.odd?
      return totals[ten_percent_of_totals_length/2]
    else
      return totals[(ten_percent_of_totals_length/2) -1..ten_percent_of_totals_length/2].reduce(:+)/2
    end
  end

  def take_off_highest_lowest(totals)
    totals.shift
    totals.pop
    return totals.map {|total| total/100.00}
  end

  def get_avg_by_day(totals)
    totals = take_off_highest_lowest(totals) unless totals.length <= 2
    return [(totals.reduce(:+)/totals.length).round(2)]
  end

  def get_ranges_for_month(totals)
    final_totals = []
    totals.each do |time, half_hour_totals|
      half_hour_totals.sort!.uniq!
      next if half_hour_totals.length <= 2
      final_totals << [time] + get_ranges_by_day(half_hour_totals)
    end
    return final_totals
  end

  def get_avg(totals)
    final_totals = []
    totals.each do |time, half_hour_totals|
      half_hour_totals.sort!.uniq
      next if half_hour_totals.length <= 2
      final_totals << [time] + get_avg_by_day(half_hour_totals)
    end
    return final_totals
  end

  def get_max_of_all_totals(ranges, most_recent_totals)
    all_totals = []
    ranges.each {|total| all_totals << total[2]}
    return all_totals.max
  end
end
