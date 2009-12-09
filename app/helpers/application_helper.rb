# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_flash_message(message = flash)
    return if message.empty?
    flash_type = message.keys.first
    content_tag :div, :id => "flash", :class => "flash_#{flash_type}" do 
      %{ <p>#{message[flash_type]}</p> }
    end
  end
  
  def css
    @style = SystemSetting.css.setting rescue nil
    stylesheet_link_tag(
                        [
                         @style[:css].try(:split), "formtastic", "formtastic_changes"
                        ].flatten.compact, :cache => true )
  end
  
  def meta_to_html
    @meta = SystemSetting.meta.setting rescue nil
    @meta.collect { |k,v|
      if k.to_sym  == :title
        content_tag(:title, v)
      else
        tag(:meta, :name => k.to_sym, :content => v.to_a.join(","))
      end
    }
  end
end
