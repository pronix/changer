class Claim < ActiveRecord::Base
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
end
