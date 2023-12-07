# taken from https://rubygems.org/gems/ddate/ but fixed typo in code
class DDate
  def initialize(gregorian_time=nil)
    @time = gregorian_time || Time.now
  end

  def month_number
    (yday-1) / 73
  end

  def month
    ["Chaos", "Discord", "Confusion", "Bureaucracy", "The Aftermath"][month_number]
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
    @time.year % 4 == 0
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

class Server < Sinatra::Application
  get '/' do
    html = "<html>"
    html += "<head>"
    html += "<title>Discordian calendar - ddate.site</title>"
    html += "<meta property='og:type' content='website'>"
    html += "<meta property='og:type' content='website'>"
    html += "<meta property='og:title' content='Discordian calendar - ddate.site'>"
    html += "<style> body { background: #f1e18d; color: black; } </style>"
    html += "<style> h1 { margin-top:2em } </style>"
    html += "<style> .info { margin-top:2em } </style>"
    html += "</head>"
    html += "</body>"
    html += "<center>"
    html += "<h1>#{DDate.new.to_s}</h1>"
    html += "<p class='info'>"
    html += "The Discordian or Erisian calendar is an alternative calendar used by some adherents of Discordianism.</br>It is specified on page 00034 of the <a href='https://principiadiscordia.com'>Principia Discordia</a>."
    html += "</p>"
    html += "</center>"
    html += "</body>"
    html += "</html>"

    html
  end
end
