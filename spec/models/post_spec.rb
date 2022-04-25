require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#add_comment' do
    let(:post) { Post.create! }

    context 'when deadlock is detected' do
      before do
        once_retried = false
        allow_any_instance_of(Comment).to receive(:save!) do |stubbed_comment|
          if once_retried
            allow(stubbed_comment).to receive(:save!).and_call_original
            stubbed_comment.save!
          else
            once_retried = true
            raise ActiveRecord::Deadlocked
          end
        end
      end

      it 'creates a comment' do
        expect { post.add_comment }.to change(Comment, :count).by(1)
      end
    end
  end
end
