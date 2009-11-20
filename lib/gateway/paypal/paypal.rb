=begin rdoc
Для работы с webmoney
=end
module LibGateway
  class Paypal
    attr_accessor :errors
    def initialize
      @errors = { }
    end
    # валидация параметров option_purse для заявки
    def valid_params(options)
      # Проверяем чтоб кошелек был валидны
      @errors = { }
      @errors[:purse_dest] = "Неверный формат кошелька" unless !options["purse_dest"].blank? &&
        options["purse_dest"] =~ /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4})\z/i
      @errors.blank?
    end
  end
end
