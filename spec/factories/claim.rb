Factory.define :claim_wmr_to_ya, :class => Claim do |c|
  c.currency_source   {|a| a.association(:wmr) }
  c.currency_receiver   {|a| a.association(:ya) }
  c.state "new"
end
