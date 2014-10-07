module Syrup::Contact

  def create(args)
    # Split comma-separated tags into an array
    tags = args[:tags].split(',') if args[:tags]
    # Create the contact
    Flapjack::Diner.create_contacts([{
      :id         => args[:id], # Passing nil is good enough to get it to create an ID for you.
      :first_name => args[:first_name],
      :last_name  => args[:last_name],
      :email      => args[:email],
      :timezone   => args[:timezone],
      :tags       => tags
    }])
  end

  def get(args)
    # Split comma-separated IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.contacts(*ids)
  end

  def update(args)
    # Split CSV arguments into arrays
    ids    = args[:ids].split(',') if args[:ids]
    tags   = args[:add_tags].split(',') if args[:add_tags]
    rtags  = args[:remove_tags].split(',') if args[:remove_tags]
    rules  = args[:add_rules].split(',') if args[:add_rules]
    rrules = args[:remove_rules].split(',') if args[:remove_rules]
    #TODO: Add support for media when available in Flapjack

    # Collect all the changes into a hash, and omit fields that aren't changing
    changes = {}
    changes[:first_name] = args[:first_name] if args[:first_name]
    changes[:last_name]  = args[:last_name] if args[:last_name]
    changes[:email]      = args[:email] if args[:email]
    changes[:timezone]   = args[:timezone] if args[:timezone_name]
#    changes[:tags]       = tags if tags
    # Apply field changes.
    if not changes.empty?
      Flapjack::Diner.update_contacts(*ids, changes)
    end

    # Loop through all of the add/remove arrays, make a call to update each one
    #TODO: This isn't working, even though it appears to be how the Diner page says to do it.
    # Maybe check the code?
    if tags
      tags.each do |tag|
        Flapjack::Diner.update_contacts(*ids, :add_tag => tag)
      end
    end
    if rtags
      rtags.each do |tag|
        Flapjack::Diner.update_contacts(*ids, :remove_tag => tag)
      end
    end
    if rules
      rules.each do |rule|
        Flapjack::Diner.update_contacts(*ids, :add_notification_rule => tag)
      end
    end
    if rrules
      rrules.each do |rule|
        Flapjack::Diner.update_contacts(*ids, :remove_notification_rule => tag)
      end
    end
  end

  def delete(args)
    # Split comma-separated IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    Flapjack::Diner.delete_contacts(*ids)
    puts "Deleting contacts:"
    puts ids
  end
end
