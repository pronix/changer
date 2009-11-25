class AddErrorsClaimToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :errors_claim, :text
  end

  def self.down
    remove_column :claims, :errors_claim
  end
end
