module AuthHelpers
  def complete_sign_in_form_as(user)
    complete_sign_in_form_with(user.email, user.password)
  end

  def complete_sign_in_form_with(email, password = 'password')
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end

  def complete_sign_up_form_with(name, email)
    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password", with: "password"
    click_button "Sign up"
  end
end
