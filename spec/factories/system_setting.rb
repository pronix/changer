Factory.define :meta_setting, :class => SystemSetting do |c|
  c.code "meta"
  c.name "Meta keyword"
  c.setting :words => ["paypal","webmoney","money_bookers"] 
end
Factory.define :css_setting, :class => SystemSetting do |c|
  c.code "css"
  c.name "Css"
  c.setting :css_prefix => "ver_1_"
end
