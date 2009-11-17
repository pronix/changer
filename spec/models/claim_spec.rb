require 'spec_helper'

describe Claim do

  describe "При создание заявки" do
    before(:each) do 
      @wmr = Factory(:wmr)
      @ya = Factory(:ya)      
    end
    
    it "должен быть валидным при верных параметрах" do 
      Factory(:path_way_wmr_to_ya, 
              :currency_source => @wmr, :currency_receiver => @ya  )
      @claim = Factory.create(:claim_wmr_to_ya, 
                              :currency_source => @wmr, :currency_receiver => @ya)
      @claim.should be_valid
      @claim.errors.should be_empty
    end
    
    it "должен установить соостояние заявки new" do 
      Factory(:path_way_wmr_to_ya, 
              :currency_source => @wmr, :currency_receiver => @ya  )
      @claim = Factory.create(:claim_wmr_to_ya, 
                              :currency_source => @wmr, :currency_receiver => @ya)
      @claim.new?.should be_true
    end
    
    it "должен быть не валидным если обе валюты одинаковы" do 
      @claim = Factory.build(:claim_wmr_to_ya, 
                              :currency_source => @wmr, :currency_receiver => @wmr)
      @claim.should_not be_valid
      @claim.errors.on(:currency_source).should_not be_empty
      @claim.errors.on(:currency_receiver).should_not be_empty      
    end
    
    it "должен быть не валидным если обмен не описан в системе" do 
      PathWay.destroy_all
      @claim = Factory.build(:claim_wmr_to_ya)
      @claim.should_not be_valid
      @claim.errors.on(:currency_source).should_not be_empty
      @claim.errors.on(:currency_receiver).should_not be_empty      
    end
    
  end

end
