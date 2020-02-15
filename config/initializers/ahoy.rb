class Ahoy::Store < Ahoy::DatabaseStore
  def user
    controller.current_participant
  end

  def authenticate(data)
    # disables automatic linking of visits and users
  end
end

# set to true for JavaScript tracking
Ahoy.api = true

# Group ips for GDPR
Ahoy.mask_ips = true

# No Cookies #GDPR!
Ahoy.cookies = false

# Geocoding overloads our redis
# Need db sideloaded without api calls
Ahoy.geocode = false
