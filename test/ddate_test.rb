require 'minitest/autorun'
require_relative '../ddate'

class DDateTest < Minitest::Test
  def test_round_trip_from_gregorian
    d = DDate.new(Time.utc(2024, 3, 1))
    back = DDate.from_discordian(d.year, month: d.month, day: d.day_of_month)
    assert_equal d.gregorian_date, back.gregorian_date
  end

  def test_st_tibs_day
    d = DDate.from_discordian(2024 + 1166, month: 'Chaos', st_tibs: true)
    assert_equal Date.new(2024, 2, 29), d.gregorian_date
  end

  def test_leap_year_offset
    d = DDate.from_discordian(3190, month: 'Chaos', day: 60)
    assert_equal Date.new(2024, 3, 1), d.gregorian_date
  end

  def test_st_tibs_rejected_in_non_leap_year
    assert_raises(ArgumentError) do
      DDate.from_discordian(2023 + 1166, month: 'Chaos', st_tibs: true)
    end
  end

  def test_greyface_to_discordian
    d = DDate.from_gregorian(Date.new(2025, 8, 14))
    assert_match(/Bureaucracy/, d.discordian_s)
    assert_match(/3191 YOLD/, d.discordian_s)
  end

  def test_round_trip_greyface_to_discordian
    original = Date.new(2024, 2, 29)
    d = DDate.from_gregorian(original)
    assert_match(/St\. Tib's Day/, d.discordian_s)
    back = DDate.from_discordian(d.year, month: d.month, st_tibs: true)
    assert_equal original, back.gregorian_date
  end
end
