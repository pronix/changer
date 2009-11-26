class Notifier < ActionMailer::Base
  default_url_options[:host] = "localhost:3000"
  
  %w{new_claim confirmed_claim complete_claim cancel_claim error_claim}.each do |method_name|

    define_method(method_name) do |claim|
      subject      I18n.t("mailer.subject.#{method_name}", :claim_id => claim.id)
      from          "changer@gmail.com"
      recipients    claim.email
      sent_on       Time.now
      body          :claim => claim
    end

  end
  
end
