class Event < ActiveRecord::Base
  serialize :parameters, Hash
  belongs_to :claim
end
