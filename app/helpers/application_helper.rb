module ApplicationHelper
  
# Return a title which wisely configures itself correctly with or without a @title definition
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
end
