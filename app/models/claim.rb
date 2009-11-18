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
  validates_presence_of :summa, :email
  validates_format_of :email, :with => /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i 
  validates_numericality_of :summa
  
  validate :valid_currency
  
  serialize :option_purse, Hash # параметры кошелька пользователя
  serialize :request_options, Hash # параметры запроса откуда создаеться заявка
  
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

  class << self 
    # TODO потом надо будет добавить проверку на время жизни заявки
    def find_claim(_id=nil)
      find_by_id(_id)
    end
  end
  aasm_column :state
  aasm_initial_state :new
  
  aasm_state :new        # новая заявка
  aasm_state :filled     # заявка заполнена
  aasm_state :confirmed  # данные потверждены и соглашение приянто
  aasm_state :pay        # заявка оплачена
  aasm_state :queue      # заявка в очереди на перечесление 
  aasm_state :complete   # заявка завершена
  aasm_state :cancel     # заявка отменена
  aasm_state :error      # заявка завершена с ошибкой

  
  # заполнили заявку
  aasm_event :fill do
    transitions :to => :filled, :from => :new
  end
  
  # потдвердили заявку
  aasm_event :confirm do
    transitions :to => :confirmed, :from => :filled
  end  
  
  # заявку оплатили
  aasm_event :payment do
    transitions :to => :pay, :from => :confirmed
  end  
  
  # заявка в очереди на перечесление денег
  aasm_event :to_queue do
    transitions :to => :queue, :from => :pay
  end  
  
  # заявка выполнена
  aasm_event :completed do
    transitions :to => :complete, :from => :queue
  end  
  
  # заявка выполнена
  aasm_event :canceled do
    transitions :to => :cancel, :from => [:new, :filled, :confirmed]
  end  
  
  # заявка не выполнена из-за ошибки
  aasm_event :erroneous  do 
    transitions :to => :error, :from => [:new, :filled, :confirmed, :pay, :complete, :cancel]
  end
end

