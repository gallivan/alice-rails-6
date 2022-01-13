module DateHelpers

  def next_monday
    Date.commercial(Date.today.year, 1+Date.today.cweek, 1)
  end

end