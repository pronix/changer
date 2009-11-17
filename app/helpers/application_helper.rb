# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_flash_message(message = flash)
    return if message.empty?
    flash_type = message.keys.first
    content_tag :div, :id => "flash", :class => "flash_#{flash_type}" do 
      %{ <p>#{message[flash_type]}</p> }
    end
  end
end
