require 'spec_helper'

describe Claim do

  describe "При создание заявки" do
    before(:each) do 
      @wmr = Factory(:webmoney_wmr)
      @pl_usd = Factory(:paypal_usd)
      
    end
    
    it "должен быть валидным при верных параметрах" do 
      Factory(:path_way_wmr_to_paypal_usd, 
              :currency_source => @wmr, :currency_receiver => @pl_usd  )
      @claim = Factory.build(:claim_wmr_to_paypal_usd, 
                              :currency_source => @wmr,
                              :currency_receiver => @pl_usd)
      @claim.should be_valid
      @claim.errors.should be_empty
    end

    it "должен установить соостояние заявки new_claim" do 
      Factory(:path_way_wmr_to_paypal_usd, 
              :currency_source => @wmr, :currency_receiver => @pl_usd  )
      @claim = Factory.create(:claim_wmr_to_paypal_usd, 
                              :currency_source => @wmr, :currency_receiver => @pl_usd)
      @claim.new_claim?.should be_true
    end

    
    it "должен быть не валидным если обмен не описан в системе" do 
      PathWay.destroy_all
      @claim = Factory.build(:claim_wmr_to_paypal_usd)
      @claim.should_not be_valid
      @claim.errors.on(:path_way).should_not be_empty
    end
    
  end

  describe "При расчета обмена валюты" do 
    before(:each) do 
      @wmr = Factory(:webmoney_wmr)
      @pl_usd = Factory(:paypal_usd)
      Factory(:path_way_wmr_to_paypal_usd, 
              :currency_source => @wmr,
              :currency_receiver => @pl_usd ,
              :fee_payment_system => 0.9, :fee => 3.2, 
              :rate => 0.035)

      @claim = Factory.create(:claim_wmr_to_paypal_usd, 
                              :currency_source => @wmr,
                              :currency_receiver => @pl_usd,
                              :email => "test@gmail.com", 
                              :summa => 500)        
      @claim.fill!
    end
    
    it "должен посчитать сумму к выдачи в новой валюте" do 
      @claim.receivable_receive.should == (500 * 0.035).round(2)
    end
  end
end
