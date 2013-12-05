require 'spec_helper'
describe Authem::ControllerSupport do
  subject { controller }

  let!(:user) { PrimaryStrategyUser.create(:email => 'some@guy.com', :password => 'password', password_confirmation: 'password') }
  let(:controller) { AuthenticatedController.new }
  let(:cookies) { MockCookies.new }
  let(:session) { {}.with_indifferent_access }
  let(:request) { double(:request) }

  before do
    controller.stub(:cookies).and_return(cookies)
    controller.stub(:session).and_return(session)
    controller.stub(:request).and_return(request)
  end

  describe '#sign_in' do
    before { controller.send(:sign_in, user) }
    its(:current_user) { should == user }
    it { session[:session_token].should_not be_nil  }
  end

  describe '#sign_out' do
    before { controller.instance_variable_set(:@current_user, double) }

    it 'resets the session' do
      session.should_receive(:delete).with(:session_token)
      controller.send(:sign_out)
      controller.send(:current_user).should be_nil
    end
  end

  describe '#current_user' do
    subject { controller.send(:current_user) }

    context 'without an established presence' do
      it { should be_nil }
    end

    context 'with a token in the session' do
      before { session[:session_token] = user.sessions.create!.token }
      it { should == user }
    end
  end

  describe '#signed_in?' do
    subject { controller.send(:signed_in?) }
    before { controller.stub(:current_user).and_return(current_user) }

    context 'when the user is signed in' do
      let(:current_user) { double }
      it { should be_true }
    end

    context 'when the user is not signed in' do
      let(:current_user) { nil }
      it { should be_false }
    end
  end

  describe '#require_user' do
    context 'with an established user' do
      before { controller.send(:sign_in, user) }
      it 'does not issue a redirect' do
        controller.should_not_receive(:redirect_to)
        controller.send(:require_user)
      end
    end

    context 'without an established user' do
      let(:url) { double(:url) }

      it 'issues a redirect' do
        request.stub(:url).and_return(url)
        request.stub(:xhr?).and_return(false)
        controller.should_receive(:redirect_to).with(:sign_in)
        controller.send(:require_user)
      end

      context 'return to url' do
        subject { session[:return_to_url] }

        before do
          controller.stub(:redirect_to)
          controller.stub(:current_user).and_return(nil)
          request.stub(:url).and_return(url)
        end

        context 'on an http request' do
          before do
            request.stub(:xhr?).and_return(false)
            controller.send(:require_user)
          end
          it { should == url }
        end

        context 'on an xhr request' do
          before do
            request.stub(:xhr?).and_return(true)
            controller.send(:require_user)
          end
          it { should be_nil }
        end
      end
    end
  end

  describe '#signed_in?' do
    subject { controller.send(:signed_in?) }
    context 'with an established user' do
      before { controller.send(:sign_in, user) }
      it { should be_true }
    end

    context 'without an established user' do
      it { should be_false }
    end
  end

  describe '#redirect_back_or_to' do
    context 'with a return_to_url' do
      before { session[:return_to_url] = :dashboard }

      it 'clears and redirects to the return to url' do
        controller.should_receive(:redirect_to).with(:dashboard, :flash => {})
        controller.send :redirect_back_or_to, :somewhere
        session[:return_to_url].should be_nil
      end
    end
  end
end
