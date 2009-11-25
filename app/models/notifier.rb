class Notifier < ActionMailer::Base
  default_url_options[:host] = "localhost:3000"

  # Новая заявка
  def new_claim(claim)
    subject       "Заявка № #{claim.md}: Создана новая заявка."
    from          "host@mail.ru"
    recipients    claim.email
    sent_on       Time.now
    body          :claim => claim
    
  end
  
  # Заявка заполнена и подтверждена
  def confirmed_claim(claim) 
    subject       "Заявка № #{claim.md}: Заявка заполнена."
    from          "host@mail.ru"
    recipients    claim.email
    sent_on       Time.now
    body          :claim => claim
  end
  
  # Заявка выполнена
  def complete_claim(claim)
    subject       "Заявка № #{claim.md}: Заявка выполнена."
    from          "host@mail.ru"
    recipients    claim.email
    sent_on       Time.now
    body          :claim => claim
  end
  
  # Заявка отменена
  def cancel_claim(claim)
    subject       "Заявка № #{claim.md}: Заявка отменена."
    from          "host@mail.ru"
    recipients    claim.email
    sent_on       Time.now
    body          :claim => claim
  end
  
  # Заявка завершилась с ошибкой
  def error_claim(claim)
    subject       "Заявка № #{claim.md}: Заявка завершена с ошибкой."
    from          "host@mail.ru"
    recipients    claim.email
    sent_on       Time.now
    body          :claim => claim
  end
  
end
