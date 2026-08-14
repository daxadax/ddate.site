require_relative 'ddate'

class Server < Sinatra::Application
  WEEKDAYS = ["Setting Orange", 'Sweetmorn', 'Boomtime', 'Pungenday', 'Prickle Prickle'].freeze

  configure do
    set :erb, layout: :layout
  end

  helpers do
    def preview_weekday(month, day, st_tibs)
      return "St. Tib's Day" if st_tibs

      month_number = DDate.resolve_month(month) || 0
      WEEKDAYS[(month_number * 73 + day.to_i) % 5]
    end

    def load_converter_vars!
      @months = DDate::MONTHS
      @weekdays = WEEKDAYS
      @direction = params['direction'] == 'to_podge' ? 'to_podge' : 'to_hodge'
      @yold = params['yold'] || DDate.new.year
      @month = params['month'] || DDate::MONTHS.first
      @day = params['day'] || 1
      @st_tibs = params['st_tibs'] == '1'
      @gf_date = params['gf_date'] || Date.today.iso8601
      @preview_weekday = preview_weekday(@month, @day, @st_tibs)
      @conversion = nil
      @conversion_error = nil
    end

    def perform_conversion!
      return unless params['consult']

      @conversion = if @direction == 'to_podge'
        DDate.from_gregorian(@gf_date)
      else
        DDate.from_discordian(
          params['yold'].to_i,
          month: params['month'],
          day: params['day']&.to_i,
          st_tibs: @st_tibs
        )
      end
    rescue ArgumentError, Date::Error => e
      @conversion_error = e.message
    end
  end

  get '/' do
    @page_title = 'Discordian calendar — ddate.site'
    @today = DDate.new.to_s
    erb :index
  end

  get '/convert' do
    @page_title = 'Perpetual Date Converter — ddate.site'
    @convert_js = true
    load_converter_vars!
    perform_conversion!
    erb :convert
  end
end
