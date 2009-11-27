Factory.define :webmoney, :class => PaymentSystem do |ps|
  ps.controller "webmoney"
  ps.name "Webmoney"
  ps.description  "Платежная система webmoney"
end
Factory.define :paypal, :class => PaymentSystem do |ps|
  ps.controller "paypal"
  ps.name "Paypal"
  ps.description  "Платежная система PayPal"
  ps.parameters :cert_id => "MJFKHQF4DFXKS",
  :cmd => "_xclick",
  :business => "parall_1258002853_biz@gmail.com",
  :return_url =>  "http://94.24.178.149:3000/gateway/paypal/done",
  :url => "http://test.paypal.com"
end
