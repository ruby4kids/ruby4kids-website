module DateSearchField  

  def date_search_to_condition (search_string)
    case search_string.downcase
    when "all future dates"
      ">"+Date.today.strftime("%Y-%m-%d")
    when "all past dates"
      "<"+Date.today.strftime("%Y-%m-%d")
    when "last week"
      ">="+(Date.today-(7-Date.today.wday+7)).strftime("%Y-%m-%d")+"&<="+(Date.today-(1-Date.today.wday+7)).strftime("%Y-%m-%d")
    when "next 30 days"
      ">"+Date.today.strftime("%Y-%m-%d")+"&<="+(Date.today+30).strftime("%Y-%m-%d")
    when "next 60 days"
      ">"+Date.today.strftime("%Y-%m-%d")+"&<="+(Date.today+60).strftime("%Y-%m-%d")
    when "next week"
      ">="+(Date.today+1-Date.today.wday+7).strftime("%Y-%m-%d")+"&<="+(Date.today+7-Date.today.wday+7).strftime("%Y-%m-%d")
    when "past 30 days"
      "<"+Date.today.strftime("%Y-%m-%d")+"&>="+(Date.today-30).strftime("%Y-%m-%d")
    when "past 60 days"
      "<"+Date.today.strftime("%Y-%m-%d")+"&>="+(Date.today-60).strftime("%Y-%m-%d")
    when "this month"
      ">='#{Date.today.year}-#{Date.today.month}-01'&<'#{Date.today.year}-"+get_month_num(Date.today.month+1).to_s+"-01'"
    when "this week"
      ">="+(Date.today+1-Date.today.wday).strftime("%Y-%m-%d")+"&<="+(Date.today+7-Date.today.wday).strftime("%Y-%m-%d")
    when "today"
       "="+Date.today.strftime("%Y-%m-%d")
    when "tomorrow"
       "="+(Date.today+1).strftime("%Y-%m-%d")
    else
      ""
    end
  end
end