class Tweet < ActiveRecord::Base

  def to_json
    super
  end

end