module Flapjack::Syrup::Contact
  def create(args)
    # Split comma-separated tags into an array
    tags = args[:tags].split(',') if args[:tags]
    # Create the email address medium to attach to the contact
    if args[:no_media]
      media = {}
    else
      media = {
        :email => {
          :address          => args[:email],
          :interval         => args[:interval],
          :rollup_threshold => args[:rollup_threshold]
      } }
    end
    # Create the contact
    id = Flapjack::Diner.create_contacts([{
      :id         => args[:id],
      :first_name => args[:first_name],
      :last_name  => args[:last_name],
      :email      => args[:email],
      :timezone   => args[:timezone],
      :tags       => tags,
      :media      => media
    }])

    # TODO: When we can get ID's back from Flapjack, add the ALL entity by default.
    # if !args[:no_all_entity]
    #   Flapjack::Diner.update_contacts(id, :add_entity => 'ALL')
    # end
    id
  end

  def get(args)
    # Split comma-separated IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.contacts(*ids)
  end

  def update(args)
    # Split CSV arguments into arrays
    ids       = args[:ids].split(',') if args[:ids]
    tags      = args[:tags].split(',') if args[:tags]
    arules    = args[:add_rules].split(',') if args[:add_rules]
    rrules    = args[:remove_rules].split(',') if args[:remove_rules]
    aentities = args[:add_entities].split(',') if args[:add_entities]
    rentities = args[:remove_entities].split(',') if args[:remove_entities]
    # TODO: Add/remove tags doesn't seem to be in the Diner codebase.
    # TODO: Add/remove media isn't supported yet but will be added when Flapjack can support it.
    # NOTE: Replacing entire array of rules and entities is NOT supported.

    # Collect all the changes into a hash, and omit fields that aren't changing
    changes = {}
    changes[:first_name] = args[:first_name] if args[:first_name]
    changes[:last_name]  = args[:last_name] if args[:last_name]
    changes[:email]      = args[:email] if args[:email]
    changes[:timezone]   = args[:timezone] if args[:timezone_name]
    changes[:tags]       = tags if tags

    # Apply field changes.
      Flapjack::Diner.update_contacts(*ids, changes) unless changes.empty?
    # Apply all notification rule and entity changes
    if arules
      arules.each do |rule|
        Flapjack::Diner.update_contacts(*ids, :add_notification_rule => rule)
      end
    end
    if rrules
      rrules.each do |rule|
        Flapjack::Diner.update_contacts(*ids, :remove_notification_rule => rule)
      end
    end
    if aentities
      aentities.each do |entity|
        Flapjack::Diner.update_contacts(*ids, :add_entity => entity)
      end
    end
    if rentities
      rentities.each do |entity|
        Flapjack::Diner.update_contacts(*ids, :remove_entity => entity)
      end
    end
  end

  def delete(args)
    # Split comma-separated IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    Flapjack::Diner.delete_contacts(*ids)
  end
end
