module Webmoney::RequestResult    # :nodoc:all

  def result_check_sign(doc)
    doc.at('//testsign/res').inner_html == 'yes' ? true : false
  end

  def result_get_passport(doc)
    tid = doc.at('/response/certinfo/attestat/row')['tid'].to_i
    recalled = doc.at('/response/certinfo/attestat/row')['recalled'].to_i
    locked = doc.at('/response/certinfo/userinfo/value/row')['locked'].to_i
    { # TODO more attestat fields...
      :attestat => ( recalled + locked > 0) ? Webmoney::Passport::ALIAS : tid,
      :created_at => Time.xmlschema(doc.at('/response/certinfo/attestat/row')['datecrt'])
    }
  end

  def result_bussines_level(doc)
    doc.at('//level').inner_html.to_i
  end

  def result_send_message(doc)
    time = doc.at('//message/datecrt').inner_html
    m = time.match(/(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
    time = Time.mktime(*m[1..6])
    { :id => doc.at('//message')['id'], :date => time }
  end

  def result_find_wm(doc)
    {
      :retval => doc.at('//retval').inner_html.to_i,
      :wmid   => (doc.at('//testwmpurse/wmid').inner_html rescue nil),
      :purse  => (doc.at('//testwmpurse/purse').inner_html rescue nil)
    }
  end

  def result_create_transaction(doc)
    
    { 
      :retval => doc.at('//retval').inner_html.to_i,
      :operation_id => doc.at('//operation')['id'],
      :operation_ts => doc.at('//operation')['ts'],
      :tranid => (doc.at('//operation/tranid').inner_html rescue nil),     
      :pursesrc => (doc.at('//operation/tranid').inner_html rescue nil),
      :pursedest => (doc.at('//operation/pursedest').inner_html rescue nil),
      :amount => (doc.at('//operation/amount').inner_html rescue nil),
      :comiss => (doc.at('//operation/comiss').inner_html rescue nil),
      :opertype => (doc.at('//operation/opertype').inner_html rescue nil),
      :period => (doc.at('//operation/period').inner_html rescue nil),
      :wminvid => (doc.at('//operation/wminvid').inner_html rescue nil),
      :orderid => (doc.at('//operation/orderid').inner_html rescue nil),
      :desc => (doc.at('//operation/desc').inner_html rescue nil),
      :datecrt => (doc.at('//operation/datecrt').inner_html rescue nil),
      :dateupd => (doc.at('//operation/dateupd').inner_html rescue nil)
      
    }
    
  end
  
end
