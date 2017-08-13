require 'rails_helper'

describe Question do
  subject { described_class.new }

  context "Relationships" do
    it { should belong_to :user }
    it { should have_many :answers }
    it { should have_many :revisions }
  end

  context "Validations" do
    it { should validate_presence_of :content }
    it { should validate_presence_of :source }
    it { should validate_presence_of :year }
  end

  context "Callbacks" do
    it "before_create: set status to pending" do
      subject.run_callbacks(:create) { true }

      expect(subject.status).to eq QuestionStatus::PENDING
    end

    it "before_save: can not edit an approved question" do
      subject.content = 'Content #1'
      subject.source  = 'wikipedia'
      subject.year    = 2017
      allow(subject).to receive(:answers).and_return(answers)
      subject.save
      subject.content = 'Content #2'

      subject.valid?

      expect(subject.errors[:base]).to eq ['Can only edit a reproved question']
    end
  end

  let :answers do
    [
        double(:answer, correct: true),
        double(:answer, correct: false),
        double(:answer, correct: false),
        double(:answer, correct: false),
        double(:answer, correct: false)
    ]
  end

  context "#status" do
    before do
      subject.content = 'Content #1'
      subject.source  = 'wikipedia'
      subject.year    = 2017

      allow(subject).to receive(:answers).and_return(answers)

      subject.save
    end

    it 'update status to approved' do
      subject.send(:approved!)

      expect(subject.status).to eq QuestionStatus::APPROVED
    end

    it 'update status to reproved' do
      subject.send(:reproved!)

      expect(subject.status).to eq QuestionStatus::REPROVED
    end

    it 'update status to pending' do
      subject.send(:pending!)

      expect(subject.status).to eq QuestionStatus::PENDING
    end
  end

  context "should validate presence of just one correct answer" do
    let :invalid_answers do
      [
          double(:answer, correct: true),
          double(:answer, correct: true),
          double(:answer, correct: false),
          double(:answer, correct: false),
          double(:answer, correct: false)
      ]
    end

    it 'valid answers' do
      allow(subject).to receive(:answers).and_return(answers)

      subject.valid?

      expect(subject.errors[:base]).to_not include 'Must have one correct answer'
    end

    it 'should show message with invalid answers' do
      allow(subject).to receive(:answers).and_return(invalid_answers)

      subject.valid?

      expect(subject.errors[:base]).to include 'Must have one correct answer'
    end
  end
end
