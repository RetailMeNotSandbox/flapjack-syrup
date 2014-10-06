# FEATURE-COMPLETE - needs testing

module Syrup::PagerDuty

  def create(args)
    # Create the credentials - no formatting or modification required.
    Flapjack::Diner.create_contact_pagerduty_credentials(@action_opts[:id], {
      :service_key => @action_opts[:service_key],
      :subdomain   => @action_opts[:subdomain],
      :username    => @action_opts[:username],
      :password    => @action_opts[:password]
    })
  end

  def get(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's returning each contact's associated pagerduty login
    ids = @action_opts[:ids].split(',') if @action_opts[:ids]
    # Get the credentials
    puts Flapjack::Diner.pagerduty_credentials(*ids)
  end

  def update(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's changing each contact's associated pagerduty login
    ids = @action_opts[:ids].split(',')
    # Collect all the changes into a hash, and omit fields that aren't changing
    changes = {}
    changes[:service_key] = @action_opts[:service_key] if @action_opts[:service_key]
    changes[:subdomain]   = @action_opts[:subdomain] if @action_opts[:subdomain]
    changes[:username]    = @action_opts[:username] if @action_opts[:username]
    changes[:password]    = @action_opts[:password] if @action_opts[:password]
    # Apply the changes
    Flapjack::Diner.update_pagerduty_credentials(*ids, changes)
  end

  def delete(args)
    # Split comma-separated IDs into an array
    # Note that these are CONTACT ID's and it's deleting each contact's associated pagerduty login
    ids = @action_opts[:ids].split(',')
    Flapjack::Diner.delete_pagerduty_credentials(*ids)
  end
end
