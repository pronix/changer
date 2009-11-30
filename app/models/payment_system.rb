class PaymentSystem < ActiveRecord::Base
  has_many :currencies # валюты платежной системы
  serialize :parameters, Hash
  
  def parameters(field=nil)
    if field.blank?
      read_attribute(:parameters)
    else
      read_attribute(:parameters) && read_attribute(:parameters)[field.to_sym]
    end
  end
  
  # резерв платежной системы (баланс сервиса на этой плат. системе)
  # 
  def reserve
    gateway = "lib_gateway/#{self.controller}".camelize.constantize
    gateway.get_balance(self.parameters)
  end
end
