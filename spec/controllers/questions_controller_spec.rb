require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do

  login_admin

  let(:user) { User.first }
  let(:answers) { [FactoryGirl.attributes_for(:answer_1), FactoryGirl.attributes_for(:answer_2), FactoryGirl.attributes_for(:answer_3),
                   FactoryGirl.attributes_for(:answer_4), FactoryGirl.attributes_for(:answer_5)] }

  let(:valid_attributes) {
    { content: 'Content of question number 1', year: 2017, source: 'wikipedia.com', status: QuestionStatus::PENDING,
      answers_attributes: answers, user: user }
  }

  let(:invalid_attributes) {
    { content: nil, year: nil, status: ' ', source: ' ' }
  }

  let(:valid_session) { {} }

  describe "GET #show" do
    it "assigns the requested question as @question" do
      question = Question.create! valid_attributes
      get :show, {:id => question.to_param}, valid_session
      expect(assigns(:question)).to eq(question)
    end
  end

  describe "GET #new" do
    it "assigns a new question as @question" do
      get :new, {}, valid_session
      expect(assigns(:question)).to be_a_new(Question)
    end
  end

  describe "GET #edit" do
    it "assigns the requested question as @question" do
      question = Question.create! valid_attributes
      get :edit, {:id => question.to_param}, valid_session
      expect(assigns(:question)).to eq(question)
    end

    it "redirect edit attempt by another non-admin user" do
      question = Question.create! valid_attributes
      sign_out user
      user = FactoryGirl.create(:visitor)
      sign_in user
      get :edit, {:id => question.to_param}, valid_session
      expect(response).to redirect_to(pages_home_path)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Question" do
        expect {
          post :create, {:question => valid_attributes}, valid_session
        }.to change(Question, :count).by(1)
      end

      it "assigns a newly created question as @question" do
        post :create, {:question => valid_attributes}, valid_session
        expect(assigns(:question)).to be_a(Question)
        expect(assigns(:question)).to be_persisted
      end

      it "redirects to the created question" do
        post :create, {:question => valid_attributes}, valid_session
        expect(response).to redirect_to(Question.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved question as @question" do
        post :create, {:question => invalid_attributes}, valid_session
        expect(assigns(:question)).to be_a_new(Question)
      end

      it "re-renders the 'new' template" do
        post :create, {:question => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { content: 'Content of question number 2', year: 2016, source: 'wikipedia.com', user: user }
      }

      it "updates the requested question" do
        question = Question.create! valid_attributes
        Revision.create!(reviewer: user, question: question, comment: 'Fix the question', status: 'reproved')
        put :update, {:id => question.to_param, :question => new_attributes}, valid_session
        question.reload
        expect(question.content).to eq('Content of question number 2')
        expect(question.year).to eq(2016)
        expect(question.source).to eq('wikipedia.com')
        expect(question.status).to eq(QuestionStatus::PENDING)
      end

      it "assigns the requested question as @question" do
        question = Question.create! valid_attributes
        put :update, {:id => question.to_param, :question => valid_attributes}, valid_session
        expect(assigns(:question)).to eq(question)
      end

      it "redirects to the question" do
        question = Question.create! valid_attributes
        Revision.create!(reviewer: user, question: question, comment: 'Fix the question', status: 'reproved')
        put :update, {:id => question.to_param, :question => new_attributes}, valid_session
        question.reload
        put :update, {:id => question.to_param, :question => new_attributes}, valid_session
        expect(response).to redirect_to(question)
      end
    end

    context "with invalid params" do
      it "assigns the question as @question" do
        question = Question.create! valid_attributes
        put :update, {:id => question.to_param, :question => invalid_attributes}, valid_session
        expect(assigns(:question)).to eq(question)
      end

      it "re-renders the 'edit' template" do
        question = Question.create! valid_attributes
        put :update, {:id => question.to_param, :question => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested question" do
      question = Question.create! valid_attributes
      expect {
        delete :destroy, {:id => question.to_param}, valid_session
      }.to change(Question, :count).by(-1)
    end

    it "redirects to the questions list" do
      question = Question.create! valid_attributes
      delete :destroy, {:id => question.to_param}, valid_session
      expect(response).to redirect_to(pages_home_path)
    end
  end

end
