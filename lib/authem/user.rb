module Authem::User
  extend ::ActiveSupport::Concern
  include Authem::BaseUser

  included do

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
