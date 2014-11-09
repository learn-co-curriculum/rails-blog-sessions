class UserSessionAuthenticator
  include ActiveModel::Model
  include ActiveModel::Validations

  validates_each :email, :password do |record, attr, value|
    record.errors.add attr, "can't be blank" if value.blank?
  end

  def save
    if valid?
      user = User.find_by_email(email) 
      if user && user.authenticate(password)
        self.user_id = user.id
      end
    end
  end

  attr_accessor :email, :password, :user_id
end
