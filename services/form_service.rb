class FormService

  def self.validate_registration(form)
    @form = form

    if @form.failed?

      @failed = Hash.new # Set up error hash
      @failed[:reg_error] = { :error_codes => [], :message => '' }

      validate_name
      validate_email
      validate_username
      validate_password
      validate_phone

      @failed
    else
      nil # no failures
    end

  end

  def self.validate_search(form)
    @form = form

    if @form.failed?

      @failed = Hash.new # set up hash
      @failed[:err] = { :error_codes => [], :message => '' }

      validate_search_terms

      @failed
    else
      nil # no failures
    end
  end

  private

  # Template method for validations
  def self.validate_field(field, type, err_code, err_message)
    if @form.failed_on? field, type
      @failed[:reg_error][:error_codes].push err_code
      @failed[:reg_error][:message] << err_message << ' ' # every message must end with a space for proper formatting
    end
  end

  # Form validation on :name field
  def self.validate_name
    validate_field :name, :present, 'r-n', 'You must enter a name.'
    validate_field :name, :alpha_space, 'r-nalpha', 'Your name must consist only of letters and spaces.'
  end

  # Form validation on :email field
  def self.validate_email
    validate_field :email, :present, 'r-e', 'You must enter an email.'
    validate_field :email, :email, 'r-einvalid', 'You must enter a correctly formatted email.'
  end

  # Form validation on :username field
  def self.validate_username
    validate_field :username, :present, 'r-u', 'You must enter a username.'
    validate_field :username, :ascii, 'r-uascii', 'Your username must only contain letters, digits, and ascii-accepted symbols.'
    validate_field :username, :length, 'r-ul', 'Your username must be between 3 and 20 characters.'
  end

  # Form validation on :password field
  def self.validate_password
    validate_field :password, :present, 'r-p', 'You must enter a password.'
    validate_field :password2, :present, 'r-p2', 'You must enter a password twice.'
    validate_field :password, :ascii, 'r-pascii', 'Your password must contain only letters, digits, and ascii symbols.'
    validate_field :password, :length, 'r-pl', 'Your password must be between 8 and 30 characters.'
    # validate passwords match
    if @form.failed_on? :same_password
      @failed[:reg_error][:error_codes].push 'r-pns'
      @failed[:reg_error][:message] << 'Your passwords do not match. '
    end

  end

  # Form validation on :phone field
  def self.validate_phone
    validate_field :phone, :present, 'r-ph', 'You must enter a phone number.'
    validate_field :phone, :int, 'r-phint', 'Your phone number must only consist of digits.'
    validate_field :phone, :length, 'r-phl', 'Your phone number must consist of only 10 digits.'
  end

  # Form validation on :search field
  def self.validate_search_terms
    validate_field :search, :present, 's-p', 'There was no search body.'
  end

end