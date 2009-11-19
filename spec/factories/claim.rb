Factory.define :claim_wmr_to_paypal_usd, :class => Claim do |c|
  c.currency_source   {|a| a.association(:webmoney_wmr) }
  c.currency_receiver   {|a| a.association(:paypal_usd) }
  c.summa  234
  c.state "new"
end
