=begin rdoc
Список обмена одной валюты на другую
=end
class PathWay < ActiveRecord::Base
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
end
