module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages
    msgs = ""
    flash.each do |msg_type, message|
        msgs << content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)}") do
          message
        end
      end

    return content_tag(:div,
      msgs.html_safe
    )
  end

end
