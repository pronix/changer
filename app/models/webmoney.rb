=begin rdoc
Для работы с webmoney
=end

class Webmoney
  class << self 
    attr_accessor :errors
    def errors
      @@errors rescue { }
    end
    # валидация параметров option_purse для заявки
    def valid_params(options)
      # Проверяем чтоб кошелек был валидны
      @@errors = { }
      @@errors[:purse_dest] = "Неверный формат кошелька" unless !options["purse_dest"].blank? &&
        options["purse_dest"] =~ /^[R|Z][0-9]{12}/
      @@errors.blank?
    end
    
  end
end
