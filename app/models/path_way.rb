=begin rdoc
Список обмена одной валюты на другую
=end
class PathWay < ActiveRecord::Base
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
  named_scope :get_currency_for_source, lambda{ |curr| { 
    :conditions => { :currency_source_id => curr }
    }}
  
  named_scope :get_currency_for_receiver, lambda{ |curr| { 
      :conditions => { :currency_receiver_id => curr }
    }}
  class << self
    
    # поиск пути по валютам
    def find_path(source, receiver)
      first  :conditions => { :currency_receiver_id => receiver.id, :currency_source_id => source.id }
    end
    
  end
end
