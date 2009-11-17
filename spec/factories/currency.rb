Factory.define :webmoney_wmz, :class => Currency do |c|
  c.payment_system  {|a| a.association(:webmoney) }
  c.name "WMZ"
  c.code "WMZ"
  c.description "$"
end

Factory.define :webmoney_wmr, :class => Currency do |c|
  c.payment_system  {|a| a.association(:webmoney) }
  c.name "WMR"
  c.code "WMR"
  c.description "Руб"
end

Factory.define :paypal_usd, :class => Currency do |c|
  c.payment_system  {|a| a.association(:paypal) }
  c.name "PayPal USD"
  c.code "USD"
  c.description "PayPal"
end

Factory.define :paypal_eur, :class => Currency do |c|
  c.payment_system  {|a| a.association(:paypal) }
  c.name "PayPal EUR"
  c.code "EUR"
  c.description "EUR PayPal"
end

