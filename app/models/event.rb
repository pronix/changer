class Event < ActiveRecord::Base
  serialize :parameters, Hash
end
