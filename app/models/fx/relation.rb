class Fx::Relation < ActiveRecord::Base
  self.table_name = "fx_relations"
  # acts_as_nested_set parent_column: "user_id",primary_column: "dealer_id",depth_column: "dealer_level",counter_cache: "dealers_count"

  belongs_to :user
  belongs_to :dealer, foreign_key: "dealer_id", class_name: "::Fx::User"
  scope :recent, -> { order('created_at DESC') }

 
  
  self.json_options={
    :only    => ["user_id"],
    :include => {
      dealer: {:only => [:total_amount], methods: [:name,:level_name,:info_dealer1_count]} 
    }
  }
end
