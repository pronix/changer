require 'spec_helper'

describe SystemSetting do
  before do 
    SystemSetting.destroy_all
  end
  it "должен создавать новый экземпляр если параметры верные" do 
    @setting = Factory(:meta_setting)
    @setting.should be_valid
  end
end
