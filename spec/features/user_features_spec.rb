require_relative '../spec_helper.rb'

describe 'user signup', :type => :feature do
  include LoginHelper

  it 'successfully signs up' do
    puts page.body
    signup_valid
  end

  it 'fails to sign up' do
    signup_invalid
  end

  it 'remains logged in after signing up' do 
    signup_valid
    click_link('New Post')
    expect(page).to have_content("#{@kitten.name}")
    expect(page.get_rack_session_key('user_id')).to_not eq(nil)
  end
end

describe 'user login', :type => :feature do
  include LoginHelper

  it 'successfully logs in' do
    login_valid
    expect(page.get_rack_session_key('user_id')).to_not eq(nil)
  end

  it 'fails to log in' do
    login_invalid
  end

  it 'successfully logs out' do
    login_valid
    click_link('Log Out')
    expect(current_path).to eq('/')
    expect(page).to have_content('Log In')
    expect(page.get_rack_session).to_not include('user_id')
  end
end

describe 'user authorization before certain actions' do 
  it 'cannot click edit link' do
    @post = @crookshanks.posts.create(name: "post title", content: "post content")
    visit '/'
    expect(page).to have_content('Log in to edit or delete your Post')
    expect(page).to have_no_content('Edit')
  end

  it 'cannot click destroy link' do
    @post = @crookshanks.posts.create(name: "post title", content: "post content")
    visit '/'
    expect(page).to have_content('Log in to edit or delete your Post')
    expect(page).to have_no_content('Destroy')
  end

  it 'cannot click new post link' do
    @post = @crookshanks.posts.create(name: "post title", content: "post content")
    visit '/'
    expect(page).to have_no_content('New Post')
  end

  it 'cannot click new comment link' do 
    @post = @crookshanks.posts.create(name: "post title", content: "post content")
    visit '/'
    click_link('post title')
    expect(current_path).to eq("/posts/#{@post.id}")
    puts page.body
    expect(page).to have_content('Log In to Comment!')
    expect(page).to have_no_content('Post a new comment:')
  end
end
