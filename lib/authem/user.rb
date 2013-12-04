module Authem::User
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do
    Authem::Config.user_class = self

    has_secure_password

    def authenticate(password)
      if password.present?
        super(password)
      else
        false
      end
    end
  end

end
