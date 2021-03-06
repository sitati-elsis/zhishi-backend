require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) { build(:user) }
  subject { build(:comment, user: user) }

  context "when the factory is build" do
    it { is_expected.to be_valid }
    it { is_expected.to be_a Comment }
  end

  context "when calling the instance methods" do
    it do
      is_expected.to respond_to(
        :user_id, :content, :comment_on_id, :comment_on_type, :votes_count,
        :user, :comment_on, :votes
      )
    end
  end

  describe "ActiveModel Validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:content) }
  end

  describe  "ActiveModel Relation" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:comment_on) }
  end

  describe "#with_associations" do
    it "has associations" do
      subject.save
      expect(Comment.all.first.association(:user).loaded?).to be false
      expect(Comment.with_associations.first.association(:user).loaded?).to be true
    end
  end

  describe "#as_indexed_json" do
    it "sets up appropriate parameters for indexing" do
      obj_format = {
        "content"=> subject.content,
        "user"=> { "name" => user.name, "email" => user.email }
      }
      expect(subject.as_indexed_json).to eql obj_format
    end
  end

  describe "#question" do
    let(:question) { create(:question) }
    let(:answer) { create(:answer, question: question) }

    it "returns question that is commented on" do
      comment = create(:comment, comment_on: question)
      expect(comment.question).to eql question
    end

    it "returns the question of the answer that is commented on" do
      comment = create(:comment_on_answer, comment_on: answer)
      expect(comment.question).to eql question
    end
  end

  context "when I create a new comment" do
    it { expect(Comment.all).to be_empty }

    it do
      subject.save
      expect(Comment.all).not_to be_empty
      expect(Comment.all.size).to eq 1
      expect(Comment.first).to eq subject
    end
  end

  context "when I create a comment on question" do
    let(:comment) { create(:comment) }

    it { expect(comment).to be_a Comment }
    it { expect(comment.comment_on).to be_a Question}
    it { expect(comment.comment_on).not_to be_an Answer}
  end

  context "when I create a comment on answer" do
    let(:comment) { create(:comment_on_answer) }

    it { expect(comment).to be_a Comment }
    it { expect(comment.comment_on).to be_an Answer}
    it { expect(comment.comment_on).not_to be_a Question}
  end

  it_behaves_like "a votable", :comment_with_votes
  it_behaves_like :activity_tracker, :comment
  it_behaves_like :activity_tracker, :comment_on_answer
  it_behaves_like :shared_notification_queue, :comment
  it_behaves_like :shared_notification_queue, :comment_on_answer

end
