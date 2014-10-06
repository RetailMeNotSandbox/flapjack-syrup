#require 'trollop'

module Syrup::PagerDuty

  def create
    tags = @action_opts[:tags].split(',') if @action_opts[:tags]
    Flapjack::Diner.create_contact_pagerduty_credentials(@action_opts[:id], {
      :service_key => @action_opts[:service_key],
      :subdomain   => @action_opts[:subdomain],
      :username    => @action_opts[:username],
      :password    => @action_opts[:password]
    })
  end

  def get
    ids = @action_opts[:ids].split(',') if @action_opts[:ids]
    puts Flapjack::Diner.pagerduty_credentials(*ids) #TODO: Check that this actually works...
  end

  def update
    ids = @action_opts[:ids].split(',')
    changes = {}
    changes[:service_key] = @action_opts[:service_key] if @action_opts[:service_key]
    changes[:subdomain]   = @action_opts[:subdomain] if @action_opts[:subdomain]
    changes[:username]    = @action_opts[:username] if @action_opts[:username]
    changes[:password]    = @action_opts[:password] if @action_opts[:password]
    Flapjack::Diner.update_pagerduty_credentials(*ids, changes)
    puts "Updating contacts:"
    puts ids
    puts changes
  end

  def delete
    ids = @action_opts[:ids].split(',')
    Flapjack::Diner.delete_pagerduty_credentials(*ids)
    puts "Deleting contacts:"
    puts ids
  end
end
