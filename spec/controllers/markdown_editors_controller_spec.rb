require 'rails_helper'

describe MarkdownEditorsController, type: :controller do
  render_views

  let!(:participant) { create :participant }

  before { sign_in participant }

  describe "GET #index" do
    it "assigns the requested markdown_editor_controller as @markdown_editor_controller" do
      get :index, params: { markdown: { markdown_text: '**Bolded**' } }

      expect(assigns(:markdown_text).strip).to eq('<p><strong>Bolded</strong></p>')
    end
  end
end
