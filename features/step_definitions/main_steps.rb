# encoding: utf-8

Если /^Я перешел (.+) "([^\"]*)"$/ do |text, page_name|
  visit path_to(page_name)
end

То /^Я должен увидеть "([^\"]*)"$/ do |arg1|
  pending
end

То /^кнопку "([^\"]*)"$/ do |arg1|

  pending
end
