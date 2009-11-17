=begin rdoc
Заявка на обмен денег
Сначала пользователь вводи две валюты 
Потом заполняет дополнительную информацию по плат. системам
Дальше потдверждает данные и соглашаеться с условием
Потом переводит денег на счет сервиса, если успешно сервис переводит на новый счет пользователя  денег в новой валюте
=end
class Claim < ActiveRecord::Base
  include AASM
  
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
  
  validates_presence_of :currency_source, :currency_receiver
  validates_presence_of :summa
  validates_numericality_of :summa
  
  validate :valid_currency
  
  serialize :option_purse, Hash
  
  def valid_currency
    
    # Валюты не долждны быть одинаквыми
    if self.currency_source == self.currency_receiver
      self.errors.add('currency_source',:should_not_be_the_same)
      self.errors.add('currency_receiver',:should_not_be_the_same)
    end

    # В PathWay должен быть прописан 
    if PathWay.find_path(self.currency_source, self.currency_receiver).blank?
      self.errors.add('currency_source',  :not_find_in_path_way)
      self.errors.add('currency_receiver',:not_find_in_path_way)
    end
    
  end
  
  aasm_column :state
  aasm_initial_state :new
  
  aasm_state :new        # новая заявка
  aasm_state :filled     # заявка заполнена
  aasm_state :confirmed  # данные потверждены и соглашение приянто
  aasm_state :pay        # заявка оплачена
  aasm_state :complete   # заявка завершена
  aasm_state :cancel     # заявка отменена
  aasm_state :error      # заявка завершена с ошибкой
  
end
