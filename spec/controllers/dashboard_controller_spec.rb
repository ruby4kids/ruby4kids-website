require 'spec_helper'

describe DashboardController do

  describe "#index" do
    context "when signed in" do
      before do
        sign_in :user, Factory(:confirmed_user)
        get :index
      end

      it { should render_template(:index) }
      it { should respond_with(:success) }
    end

    context "when signed out" do
      before do
        get :index
      end

      it { should redirect_to("the sign in page") { new_user_session_url } }
    end
  end

end
