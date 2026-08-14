# taken from https://rubygems.org/gems/ddate/ but fixed typo in code
require 'date'

class DDate
  MONTHS = ["Chaos", "Discord", "Confusion", "Bureaucracy", "The Aftermath"].freeze

  def initialize(gregorian_time=nil)
    @time = gregorian_time || Time.now
  end

  def self.from_gregorian(date)
    date = Date.parse(date.to_s) unless date.is_a?(Date)
    new(Time.utc(date.year, date.month, date.day))
  end

  def self.from_discordian(yold, month:, day: nil, st_tibs: false)
    gregorian_year = yold - 1166

    if st_tibs
      raise ArgumentError, "St. Tib's Day only occurs in leap years" unless tib_year?(gregorian_year)
      return new(Time.utc(gregorian_year, 2, 29))
    end

    month_number = resolve_month(month)
    raise ArgumentError, 'Invalid month' unless month_number
    raise ArgumentError, 'Day must be 1-73' unless day && day >= 1 && day <= 73

    discordian_yday = month_number * 73 + day
    gregorian_yday = tib_year?(gregorian_year) && discordian_yday >= 60 ? discordian_yday + 1 : discordian_yday
    max_yday = tib_year?(gregorian_year) ? 366 : 365
    raise ArgumentError, 'Invalid date for year' if gregorian_yday < 1 || gregorian_yday > max_yday

    new(Time.utc(gregorian_year) + (gregorian_yday - 1) * 86_400)
  end

  def self.resolve_month(month)
    return month if month.is_a?(Integer) && month.between?(0, 4)
    return month - 1 if month.is_a?(Integer) && month.between?(1, 5)

    MONTHS.index { |name| name.casecmp?(month.to_s) }
  end

  def self.tib_year?(year)
    year % 4 == 0
  end

  def gregorian_date
    Date.new(@time.year, @time.month, @time.day)
  end

  def gregorian_s
    gregorian_date.strftime('%A, %B %-d, %Y')
  end

  def discordian_s
    return "St. Tib's Day, #{year} YOLD" if tibs_day?

    holyday_suffix = holyday ? " — holyday of #{holyday}" : ''
    "#{day_of_week_name}, #{day_of_month} #{month} #{year} YOLD#{holyday_suffix}"
  end

  def month_number
    (yday-1) / 73
  end

  def month
    MONTHS[month_number]
  end

  def day_of_month
    yday % 73 == 0 ? 73 : yday % 73
  end

  def day_of_week
    return -1 if tibs_day?
    yday % 5
  end

  def day_of_week_name
    return "St. Tib's Day" if tibs_day?
    ["Setting Orange", 'Sweetmorn', 'Boomtime', 'Pungenday', 'Prickle Prickle'][day_of_week]
  end

  def year
    @time.year + 1166
  end

  def holyday
    case day_of_month
    when 5
      ["Mungday", "Mojoday", "Syaday", "Zaraday", "Maladay"][month_number]
    when 50
      ["Chaoflux", "Discoflux", "Confuflux", "Bureflux", "Afflux"][month_number]
    else
      "St. Tib's Day" if tibs_day?
    end
  end

  def to_s(format_str="Today is %W[, %d] %M in the YOLD %y{ It is the holyday of %H}")
    format(format_str)
  end

  def format(str)
    formattings = [["%w","day_of_week"],
                   ["%W","day_of_week_name"],
                   ["%d","day_of_month"],
                   ["%m","month_number"],
                   ["%M","month"],
                   ["%H","holyday"],
                   ["%y","year"]]
    formattings.each do |from,to|
      str.gsub!(from,eval(to).to_s)
    end
    bracketings = [["{}","!holyday or tibs_day?"],
                   ["[]","tibs_day?"]]
    bracketings.each do |wrappers,condition|
      if eval(condition)
        regex = Regexp.new("\\" + wrappers[0,1] + ".*" + "\\" + wrappers[1,1])
      else
        regex = Regexp.new("[\\" + wrappers[0,1] + "\\" + wrappers[1,1] + "]")
      end
      str.gsub!(regex,"")
    end
    str
  end

  def tib_year?
    self.class.tib_year?(@time.year)
  end

  def tibs_day?
    tib_year? && @time.yday == 31+29
  end

  private

  def yday
    return (@time.yday-1) if tib_year? and @time.yday > 60
    @time.yday
  end
end
