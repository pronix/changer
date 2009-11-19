=begin rdoc
Заявка на обмен денег
Сначала пользователь вводи две валюты 
Потом заполняет дополнительную информацию по плат. системам
Дальше потдверждает данные и соглашаеться с условием
Потом переводит денег на счет сервиса, если успешно сервис переводит на новый счет пользователя  денег в новой валюте
=end
class Claim < ActiveRecord::Base
  include AASM
  attr_protected :receivable, :fee, :service_fee
  attr_accessor :agree  
  
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
  belongs_to :path_way, :class_name => "PathWay"  
  
  serialize :option_purse, Hash # параметры кошелька пользователя
  serialize :request_options, Hash # параметры запроса откуда создаеться заявка
  
  
  validates_presence_of :currency_source, :currency_receiver
  validates_presence_of :path_way, :message => "по выбранной схеме не поддерживаеться"
  
  validates_presence_of :summa
  validates_presence_of :email, :if => lambda{ |t| !t.new_record? }
  validates_format_of :email, :with => /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i ,
  :if => lambda{ |t| !t.new_record? }
  validates_numericality_of :summa
  
    
  before_validation_on_create :set_path_way
  def set_path_way
    self.path_way = PathWay.find_path(self.currency_source, self.currency_receiver)
  end
  
  
# Платежная система (источник)
  def payment_system_source
    currency_source.payment_system
  end
  
  # Платежная система (приемник)  
  def payment_system_receiver
    currency_receiver.payment_system
  end
  
  # Параметры для урла на оплату заявки
  def pay_action
    { :controller => "gateway/#{payment_system_source.controller.downcase}", :action => :pay }
  end
  
  # Параметры для урла на заполнения данных заявки
  def filling_action
    { :controller => "gateway/#{payment_system_receiver.controller.downcase}" }
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
  aasm_state :filled,    :enter => :exchange # заявка заполнена
  aasm_state :confirmed  # данные потверждены и соглашение приянто
  
  aasm_state :pay        # заявка оплачена
  
  aasm_state :queue      # заявка в очереди на перечесление 
  aasm_state :complete   # заявка завершена
  
  aasm_state :cancel     # заявка отменена
  aasm_state :error      # заявка завершена с ошибкой

  
  # заполнили заявку
  aasm_event :fill do
    transitions :to => :filled, :from => [:new, :confirmed]
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
  
  # Вычисляем обмен валюты
  def exchange
    # поля в таблице
    # summa - исходная сумма
    # fee - сумма комисии платежной системы источник
    # fee_service - сумма комисии по сервиса
    # receivable_source - сумма к получение в исходной валюте
    # receivable_receive - сумма к получение в конечной валюте
    # rate - курс, начальной валюты к конечной

    self.fee = (self.summa / 100.0)* self.path_way.fee_payment_system.to_f
    self.service_fee = (self.summa / 100.0)* self.path_way.fee.to_f
    self.receivable_source = self.summa - (self.fee + self.service_fee)
    self.receivable_receive = self.receivable_source * self.path_way.rate
  end
end

