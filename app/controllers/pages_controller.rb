class PagesController < ApplicationController
  def contact
    @page_title = "Contact"
  end

  def privacy
    @page_title = "Privacy"
  end

  def terms
    @page_title = "Terms of Use"
  end

  def faq
    @page_title = "FAQ"
  end

  def cookies_info
    @page_title = "Cookies"
  end
end
