{
    :time => "%h:%m",
    :short_date => '%x',
    :long_date => '%a, %b %d, %Y',
    :us => '%m/%d/%Y %I:%M %p',
    :us_date => '%m/%d/%Y',
    :us_time => '%I:%M %p',
    :my_date => '%Y.%m.%d',
    :alice_date => '%Y-%m-%d',
    :alice_date_short => '%m-%d',
    :alice_date2 => '%Y%m%d',
    :alice_time => '%a %b %d %I:%M%p',
    :alice_time_short => '%b %d %I:%M%p'
}.each do |k, v|
  Time::DATE_FORMATS.update(k => v)
end
