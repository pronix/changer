class Currency < ActiveRecord::Base
  
  validates_presence_of :name, :code
  validates_presence_of :payment_system
  validates_uniqueness_of :code, :scope => [:payment_system_id]
  
  serialize :parameters, Hash
  
  belongs_to :payment_system
  has_many :path_ways, :class_name => "PathWay",
  :readonly => true, :finder_sql => %q{ 
              SELECT DISTINCT path_ways.*
              FROM path_ways
              WHERE currency_source_id = (#{ self.id }) 
                    OR
                    currency_receiver_id = (#{ self.id })
  }
  
  
  def parameters(field=nil)
    if field.blank?
      read_attribute(:parameters)
    else
      read_attribute(:parameters) && read_attribute(:parameters)[field.to_sym]
    end
  end
end
