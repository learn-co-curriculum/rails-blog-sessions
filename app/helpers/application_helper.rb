module ApplicationHelper
  def controller_name_and_action
    "#{params[:controller]}-#{params[:action]}"
  end
end
