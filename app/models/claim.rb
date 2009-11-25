=begin rdoc
Заявка на обмен денег
Сначала пользователь вводи две валюты 
Потом заполняет дополнительную информацию по плат. системам
Дальше потдверждает данные и соглашаеться с условием
Потом переводит денег на счет сервиса, если успешно сервис переводит на новый счет пользователя  денег в новой валюте
=end
require "gateway/paypal/paypal"
require "gateway/webmoney/webmoney"

class Claim < ActiveRecord::Base
  include AASM
  attr_protected :receivable, :fee, :service_fee
  attr_accessor :agree  
  
  belongs_to :currency_source, :class_name => "Currency"
  belongs_to :currency_receiver, :class_name => "Currency" 
  belongs_to :path_way, :class_name => "PathWay"  
  has_many :events do 
    # Новая заявка
    def new_claim
      
    end
  end
  
  serialize :option_purse, Hash # параметры кошелька пользователя
  serialize :request_options, Hash # параметры запроса откуда создаеться заявка
  serialize :payment_options, Hash # параметры которые вернулись от плат. системы при оплате
  serialize :response_transfert, Hash # параметры которые вернулись от плат. системы при переводе денег
  
  validates_presence_of :currency_source, :currency_receiver
  validates_presence_of :path_way, :message => "по выбранной схеме не поддерживаеться"
  
  validates_presence_of :summa
  validates_presence_of :email, :if => lambda{ |t| !t.new_record? }
  validates_format_of :email, :with => /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i ,
  :if => lambda{ |t| !t.new_record? }
  validates_numericality_of :summa
  
  validates_acceptance_of :agree, :if => lambda{ |t| t.filled? }
  
  before_validation_on_create :set_path_way
  def set_path_way
    self.path_way = PathWay.find_path(self.currency_source, self.currency_receiver)
  end


  after_create :set_md5
  def set_md5
    self.md5 = Digest::MD5.hexdigest([self, Time.now.to_i].join)    
    save
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
  
  aasm_state :new,       :enter => :new_claim # новая заявка
  aasm_state :filled,    :enter => :exchange # заявка заполнена
  aasm_state :confirmed,  :enter => :confirmed_claim # данные потверждены и соглашение приянто
  
  aasm_state :pay,       :enter => :to_queue  # заявка оплачена
  aasm_state :complete,  :enter => :complete_claim # заявка завершена
  
  aasm_state :cancel,    :enter => :cancel_claim  # заявка отменена
  aasm_state :error,     :enter => :error_claim # заявка завершена с ошибкой

  
  # заполнили заявку
  aasm_event :fill do
    transitions :to => :filled, :from => [:new, :confirmed]
  end
    
  # заполнили заявку
  aasm_event :edit do
    transitions :to => :new, :from => :filled
  end
  
  # потдвердили заявку
  aasm_event :confirm do
    transitions :to => :confirmed, :from => :filled
  end  
  
  # заявку оплатили
  aasm_event :payment do
    transitions :to => :pay, :from => :confirmed
  end  
  
  # # заявка в очереди на перечесление денег
  # aasm_event :to_queue do
  #   transitions :to => :queue, :from => :pay
  # end  
  
  # заявка выполнена
  aasm_event :completed do
    transitions :to => :complete, :from => :pay
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
  
  # Помещаем заявку в очередь на оплату
  def to_queue
    self.send_later(:transfert)
  end
  
  # Выполняем перевод денего в новую платежныю систему пользователя
  def transfert
    gateway = "lib_gateway/#{self.payment_system_receiver.controller}".camelize.constantize.new
    if gateway.transfert(self)
      self.completed!      
    else
      self.erroneous!      
    end  
  end
  
  
  # Создание сообщение для логирования по заявке и отправка сообщения на почту 
  # 
  
  # Новая заявка
  def new_claim
  end
  
  # Заявка заполнена
  def confirmed_claim
  end
  
  # Заявка выполнена
  def complete_claim
  end
  
  # Заявка отменена
  def cancel_claim
  end
  
  # Заявка завершилась с ошибкой
  def error_claim
    Notifier.deliver_error_claim(self)
    # Notifier.send("deliver_error_claim",self)
  end
  
end

