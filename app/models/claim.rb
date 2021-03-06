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
  has_many :events, :dependent => :delete_all, :extend => EventExtension 
  
  serialize :option_purse, Hash # параметры кошелька пользователя
  serialize :request_options, Hash # параметры запроса откуда создаеться заявка
  serialize :payment_options, Hash # параметры которые вернулись от плат. системы при оплате
  serialize :response_transfert, Hash # параметры которые вернулись от плат. системы при переводе денег
  serialize :errors_claim, Hash # ошибки возникшие по заявке
  
  validates_presence_of :currency_source, :currency_receiver
  validates_presence_of :path_way, :message => "по выбранной схеме не поддерживаеться"
  
  validates_presence_of :summa

  validates_presence_of :email, :if => lambda{ |t| !t.new_record?  }
  validates_format_of :email, :with => /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i ,
  :if => lambda{ |t| !t.new_record? }
  validates_numericality_of :summa, :greater_than  => 0
  
  validates_acceptance_of :agree, :if => lambda{ |t| t.filled? }
  
  before_validation_on_create :set_path_way
  def set_path_way
    self.path_way = PathWay.find_path(self.currency_source, self.currency_receiver) if self.currency_source &&
      self.currency_receiver
  end

  # после создания новой заявки
  # создаем хэш и записываем собыитие что заявка создана
  after_create :set_md5
  def set_md5
    self.md5 = Digest::MD5.hexdigest([self, Time.now.to_i].join)    
    events.new_claim
    save_with_validation(false)
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
  aasm_initial_state :new_claim
  
  aasm_state :new_claim                              # новая заявка
  aasm_state :filled,    :enter => :exchange         # заявка заполнена
  aasm_state :confirmed, :enter => :confirmed_claim  # данные потверждены и соглашение приянто
  
  aasm_state :pay,       :enter => :to_queue         # заявка оплачена
  aasm_state :complete,  :enter => :complete_claim   # заявка завершена
  
  aasm_state :cancel,    :enter => :cancel_claim     # заявка отменена
  aasm_state :error,     :enter => :error_claim      # заявка завершена с ошибкой

  
  # заполнили заявку
  aasm_event :fill do
    transitions :to => :filled, :from => [:new_claim, :confirmed], :guard => :valid_reserv?
  end
    
  # заполнили заявку
  aasm_event :edit do
    transitions :to => :new_claim, :from => :filled
  end
  
  # потдвердили заявку
  aasm_event :confirm do
    transitions :to => :confirmed, :from => :filled
  end  
  
  # заявку оплатили
  aasm_event :payment do
    transitions :to => :pay, :from => :confirmed
  end  
  
  # заявка выполнена
  aasm_event :completed do
    transitions :to => :complete, :from => :pay
  end  
  
  # заявка выполнена
  aasm_event :canceled do
    transitions :to => :cancel, :from => [:new_claim, :filled, :confirmed]
  end  
  
  # заявка не выполнена из-за ошибки
  aasm_event :erroneous  do 
    transitions :to => :error, :from => [:new_claim, :filled, :confirmed, :pay, :complete, :cancel]
  end
  
  # проверяем хватит ли денег в обменеке
  def valid_reserv?
    # self.fee = (self.summa / 100.0)* self.path_way.fee_payment_system.to_f
    # self.service_fee = (self.summa / 100.0)* self.path_way.fee.to_f
    # self.receivable_source = self.summa - (self.fee + self.service_fee)
    # self.receivable_receive = (self.receivable_source * self.path_way.rate).round(2)
    self.receivable_receive = (self.summa * self.path_way.rate).round(2)
    errors.add("reserve", "excess_reserve") if self.receivable_receive >= self.payment_system_receiver.reserve
    errors.blank?
  end
  # Вычисляем обмен валюты и отправляем что создана новая заявка
  # TODO
  # ни каких % комиссии высчитываться не будет
  # Будут две суммы: начальная и конечная.
  # Начальная - сумма которую пользователь перечислит на наш счет
  # Конечная - сумма которую мы перечисли на счет пользователя
  def exchange
    # поля в таблице
    # summa - исходная сумма
    # fee - сумма комисии платежной системы источник
    # fee_service - сумма комисии по сервиса
    # receivable_source - сумма к получение в исходной валюте
    # receivable_receive - сумма к получение в конечной валюте
    # rate - курс, начальной валюты к конечной

    # self.fee = (self.summa / 100.0)* self.path_way.fee_payment_system.to_f
    # self.service_fee = (self.summa / 100.0)* self.path_way.fee.to_f
    # self.receivable_source = self.summa - (self.fee + self.service_fee)
    # self.receivable_receive = (self.receivable_source * self.path_way.rate).round(2)
    
    self.receivable_receive = (self.summa * self.path_way.rate).round(2)
    Notifier.send_later(:deliver_new_claim, self)            
  end
  
  # Помещаем заявку в очередь на оплату
  def to_queue
    self.send_later(:transfert)
  end
  
  
  # Выполняем перевод денего в новую платежныю систему пользователя
  def transfert
    require "lib/gateway/#{self.payment_system_receiver.controller}/#{self.payment_system_receiver.controller}"    
    gateway = "lib_gateway/#{self.payment_system_receiver.controller}".camelize.constantize.new
    if gateway.transfert(self)
      self.completed!      
    else
      self.erroneous!      
    end  
  end
  


  # Создание сообщение для логирования по заявке и отправка сообщения на почту 

  %w{ confirmed_claim complete_claim cancel_claim error_claim }.each do |method_name|
    define_method(method_name) do 
      Notifier.send_later("deliver_#{method_name}".to_sym, self)        
      events.send(method_name.to_sym)
    end
  end

  
  def display_path_way
    path_way.description
  end
  
end


