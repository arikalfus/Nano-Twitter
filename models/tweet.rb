class Tweet < ActiveRecord::Base
    has_many :tags

  def to_json
    super
  end

end
