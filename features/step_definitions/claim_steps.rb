# encoding: utf-8


Given /^the following claims:$/ do |claims|
  Claim.create!(claims.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) claim$/ do |pos|
  visit claims_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following claims:$/ do |expected_claims_table|
  expected_claims_table.diff!(table_at('table').to_a)
end
