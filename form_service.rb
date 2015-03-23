require 'sinatra/formkeeper'


class FormService

  def self.validate_registration(form)

    if form.failed?
      failed = Hash.new # Set up error hash

      # Note: All error messages must end with a space for proper formatting.
      failed[:reg_error] = { :error_codes => [], :message => '' }

      # Form failed on :name
      if form.failed_on? :name, :present
        failed[:reg_error][:error_codes].push 'r-n'
        failed[:reg_error][:message] << 'You must enter a name. '
      elsif form.failed_on? :name, :alpha_space
        failed[:reg_error][:error_codes].push 'r-nalpha'
        failed[:reg_error][:message] << 'Your name must consist only of letters and spaces. '
      end

      # Form failed on :email
      if form.failed_on? :email, :present
        failed[:reg_error][:error_codes].push 'r-e'
        failed[:reg_error][:message] << 'You must enter an email. '
      elsif form.failed_on? :email, :email
        failed[:reg_error][:error_codes].push 'r-einvalid'
        failed[:reg_error][:message] << 'You must enter a correctly formatted email. '
      end

      # Form failed on :username
      if form.failed_on? :username, :present
        failed[:reg_error][:error_codes].push 'r-u'
        failed[:reg_error][:message] << 'You must enter a username. '
      elsif form.failed_on? :username, :ascii
        failed[:reg_error][:error_codes].push 'r-uascii'
        failed[:reg_error][:message] << 'Your username must only contain letters, digits, and ascii symbols. '
      elsif form.failed_on? :username, :length
        failed[:reg_error][:error_codes].push 'r-ul'
        failed[:reg_error][:message] << 'Your username must be between 3 and 20 characters. '
      end

      # Form failed on :password or :password2
      if form.failed_on? :password, :present
        failed[:reg_error][:error_codes].push 'r-p'
        failed[:reg_error][:message] << 'You must enter a password. '
      elsif form.failed_on? :password2, :present
        failed[:reg_error][:error_codes].push 'r-p2'
        failed[:reg_error][:message] << 'You must enter your password twice. '
      elsif form.failed_on? :password, :ascii
        failed[:reg_error][:error_codes].push 'r-pascii'
        failed[:reg_error][:message] << 'Your password must contain only letters, digits, and ascii symbols. '
      elsif form.failed_on? :password, :length
        failed[:reg_error][:error_codes].push 'r-pl'
        failed[:reg_error][:message] << 'Your password must be between 8 and 30 characters. '
      elsif form.failed_on? :same_password
        failed[:reg_error][:error_codes].push 'r-pns'
        failed[:reg_error][:message] << 'Your passwords do not match. '
      end

      # Form failed on :phone
      if form.failed_on? :phone, :present
        failed[:reg_error][:error_codes].push 'r-ph'
        failed[:reg_error][:message] << 'You must enter a phone. '
      elsif form.failed_on? :phone, :int
        failed[:reg_error][:error_codes].push 'r-phint'
        failed[:reg_error][:message] << 'Your phone number must only consist of digits. '
      elsif form.failed_on? :phone, :length
        failed[:reg_error][:error_codes].push 'r-phl'
        failed[:reg_error][:message] << 'Your phone number must contain 10 digits (US numbers only). '
      end

      failed
    else
      nil
    end

  end

end