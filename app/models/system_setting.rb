class SystemSetting < ActiveRecord::Base
  validates_uniqueness_of :code
  validates_presence_of :code, :name
  serialize :setting, Hash
  
  class << self
    def meta
      find_by_code "meta"
    end
    def css
      find_by_code "css"
    end
  end
end
