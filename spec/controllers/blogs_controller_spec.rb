require 'rails_helper'

describe BlogsController, type: :controller do
  render_views

  let!(:blog_1)      { create(:blog) }
  let!(:blog_2)      { create(:blog) }
  let!(:unpublished) { create(:blog, published: false, participant_id: author.id) }

  let(:participant) { create(:participant) }
  let(:author)      { create(:participant) }
  let(:admin)       { create(:participant, :admin) }

  describe 'GET #index' do
    context 'public participant' do
      before { get :index }

      it { expect(assigns(:blogs)).to eq [blog_1, blog_2] }
      it { expect(response).to render_template :index }
    end

    context 'author' do
      before do
        sign_in(author)
        get :index
      end

      it { expect(assigns(:blogs)).to eq [blog_1, blog_2, unpublished] }
      it { expect(response).to render_template :index }
    end

    context 'admin' do
      before do
        sign_in(admin)
        get :index
      end

      it { expect(assigns(:blogs)).to eq [blog_1, blog_2, unpublished] }
      it { expect(response).to render_template :index }
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: blog_1.id }

      expect(response).to be_success
    end
  end

  describe "GET #show via slug" do
    it "returns a success response" do
      get :show, params: { id: blog_1.slug }

      expect(response).to be_success
    end
  end
end
