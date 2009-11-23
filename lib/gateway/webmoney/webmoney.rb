=begin rdoc
Для работы с webmoney
=end
module LibGateway
  class Webmoney
    attr_accessor :errors
    def initialize
      @errors = { }
    end
    # валидация параметров option_purse для заявки
    def valid_params(options)
      # Проверяем чтоб кошелек был валидны
      @errors = { }
      @errors[:purse_dest] = "Неверный формат кошелька" unless !options["purse_dest"].blank? &&
        options["purse_dest"] =~ /^[R|Z]|E|U|D[0-9]{12}/
      @errors.blank?
    end
  end
end
