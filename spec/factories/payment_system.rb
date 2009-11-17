Factory.define :webmoney, :class => PaymentSystem do |ps|
  ps.controller "webmoney"
  ps.name "Webmoney"
  ps.description  "Платежная система webmoney"
end
Factory.define :paypal, :class => PaymentSystem do |ps|
  ps.controller "paypal"
  ps.name "Paypal"
  ps.description  "Платежная система PayPal"
end
