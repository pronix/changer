class PaymentSystem < ActiveRecord::Base
  has_many :currencies # валюты платежной системы
  serialize :parameters, Hash
end
