class Post < ApplicationRecord
  has_many :comments

  def add_comment
    retries = 0
    begin
      ApplicationRecord.transaction do
        comment = Comment.new(post_id: id)
        comment.save!
      end
    rescue ActiveRecord::Deadlocked => e
      if retries < 1
        retries += 1
        retry
      else
        raise e
      end
    end
  end
end
