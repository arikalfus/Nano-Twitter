class Tweet < ActiveRecord::Base
    has_many :tags
    belongs_to :user

  def to_json
    super
  end

end
