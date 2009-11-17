Factory.define :path_way_wmz_to_paypal_usd, :class => PathWay do |pw|
  pw.currency_source    {|a| a.association(:wmz) }
  pw.currency_receiver  {|a| a.association(:paypal_usd) }  
  pw.percent 1
  pw.description  "Меняем WMZ на PayPal"
end

Factory.define :path_way_wmr_to_paypal_usd, :class => PathWay do |pw|
  pw.currency_source    {|a| a.association(:wmr) }
  pw.currency_receiver  {|a| a.association(:paypal_usd) }  
  pw.percent 1
  pw.description  "Меняем WMR на PayPal USD"
end

Factory.define :path_way_paypal_usd_to_wmr, :class => PathWay do |pw|
  pw.currency_source    {|a| a.association(:paypal_usd) }
  pw.currency_receiver  {|a| a.association(:wmr) }  
  pw.percent 1
  pw.description  "Меняем PayPal USD на WMR"
end

Factory.define :path_way_paypal_usd_to_wmz, :class => PathWay do |pw|
  pw.currency_source    {|a| a.association(:paypal_usd) }
  pw.currency_receiver  {|a| a.association(:wmz) }  
  pw.percent 1
  pw.description  "Меняем PayPal USD на WMZ"
end
