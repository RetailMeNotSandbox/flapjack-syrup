module Syrup::PagerDuty

  def create(args)
    # Create the credentials - no formatting or modification required.
    # NOTE: Diner considers all four required as of 1.0, even though Flapjack does not.
    # https://github.com/flapjack/flapjack-diner/issues/39
    Flapjack::Diner.create_contact_pagerduty_credentials(args[:id], [{
      :service_key => args[:service_key],
      :subdomain   => args[:subdomain],
      :username    => args[:username],
      :password    => args[:password]
    }])
  end

  def get(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's returning each contact's associated pagerduty login
    ids = args[:ids].split(',') if args[:ids]
    # Get the credentials
    print_json Flapjack::Diner.pagerduty_credentials(*ids)
  end

  def update(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's changing each contact's associated pagerduty login
    ids = args[:ids].split(',')
    # Collect all the changes into a hash, and omit fields that aren't changing
    changes = {}
    changes[:service_key] = args[:service_key] if args[:service_key]
    changes[:subdomain]   = args[:subdomain] if args[:subdomain]
    changes[:username]    = args[:username] if args[:username]
    changes[:password]    = args[:password] if args[:password]
    # Apply the changes
    Flapjack::Diner.update_pagerduty_credentials(*ids, changes)
  end

  def delete(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's deleting each contact's associated pagerduty login
    ids = args[:ids].split(',')
    Flapjack::Diner.delete_pagerduty_credentials(*ids)
  end
end
