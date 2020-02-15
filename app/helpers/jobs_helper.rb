module JobsHelper
  def flag(country)
    alpha3 = ISO3166::Country.find_country_by_alpha2(country).alpha3.downcase
    "<span class='flag flag-#{alpha3}'></span>".html_safe if alpha3.present?
  end
end
