
module EventExtension
    # Новая заявка
    def new_claim 
      build({ 
              :message => "Создана новая заявка ##{proxy_owner.id} : #{proxy_owner.md5}",
              :parameters => proxy_owner.request_options
            })
    end
    
    def confirmed_claim
      build({ 
              :message => "Заявка потверждена и отправлена на оплату ##{proxy_owner.id} : #{proxy_owner.md5}"
            })
    end

    def complete_claim
      build({ :message => "Заявка завершена ##{proxy_owner.id} : #{proxy_owner.md5}", 
              :parameters => proxy_owner.response_transfert
            })
    end
    
    def cancel_claim
      build({ 
              :message => "Заявка отменена ##{proxy_owner.id} : #{proxy_owner.md5}",
              :parameters => proxy_owner.errors_claim
            })
    end
  
    def error_claim
      build({ 
              :message => "Заявка завершена с ошибкой ##{proxy_owner.id} : #{proxy_owner.md5}",
              :parameters => proxy_owner.errors_claim
            })
    end
    
end
