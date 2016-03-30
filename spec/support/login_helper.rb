module LoginHelper
  def login_valid
    visit '/'
    click_link('Log In')
    expect(current_path).to eq('/login')
    fill_in(:email, :with => @crookshanks.email)
    fill_in(:password, :with => @crookshanks.password)
    puts page.body
    click_button('Log In')
    expect(current_path).to eq('/')
    expect(page).to have_content("Hello, #{@crookshanks.name}!")
  end

  def login_invalid
    visit '/'
    click_link('Log In')
    expect(current_path).to eq('/login')
    fill_in(:email, :with => "Not")
    fill_in(:password, :with => "signed up")
    click_button('Log In')
    expect(current_path).to eq('/sessions')
    expect(page).to have_content('Log In')
  end

  def signup_valid
    visit '/'
    click_link('Sign Up')
    expect(current_path).to eq('/signup')
    fill_in("Name", :with => @kitten.name)
    fill_in("Email", :with => @kitten.email)
    fill_in("Password", :with => @kitten.password)
    fill_in("Password confirmation", :with => @kitten.password_confirmation)
    click_button('Sign Up')
    expect(current_path).to eq('/')
    visit '/users'
    expect(page).to have_content("#{@kitten.name}")
  end

  def signup_invalid
    visit '/'
    click_link('Sign Up')
    expect(current_path).to eq('/signup')
    fill_in("Name", :with => @invalid_user.name)
    fill_in("Email", :with => @invalid_user.email)
    fill_in("Password", :with => @invalid_user.password)
    fill_in("Password confirmation", :with => @invalid_user.password_confirmation)
    expect(current_path).to eq('/signup')
  end

end