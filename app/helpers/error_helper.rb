module ErrorHelper
  def pretty_error_code(code)
    chars = code.to_s.split('')
    if chars.length == 3 && chars[1] == '0'
      <<~HTML.html_safe
        <span class="display-1">#{chars[0]}</span>
        <div class="logomark"></div>
        <span class="display-1">#{chars[2]}</span>
      HTML
    else
      <<~HTML.html_safe
        <span class="display-1">#{code}</span>
      HTML
    end
  end
end
