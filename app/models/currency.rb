class Currency < ActiveRecord::Base
  
  validates_presence_of :name, :code
  validates_presence_of :payment_system
  validates_uniqueness_of :code, :scope => [:payment_system_id]
  
  belongs_to :payment_system
  has_many :path_ways, :class_name => "PathWay",
  :readonly => true, :finder_sql => %q{ 
              SELECT DISTINCT path_ways.*
              FROM path_ways
              WHERE currency_source_id = (#{ self.id }) 
                    OR
                    currency_receiver_id = (#{ self.id })
  }
  
  
end
