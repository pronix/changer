class PaymentSystem < ActiveRecord::Base
  has_many :currencies # валюты платежной системы
end
