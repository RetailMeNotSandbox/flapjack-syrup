# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Syrup::Entity

  # TODO: Determine whether to keep create and update in the codebase.
  # There is NO delete option, so it probably makes more sense to force people to use programmatic methods.
  # Matt suggested that if we dont, we should restructure the CLI:
  # "syrup maintenance [un]scheduled check|entity create|update|delete"

  def get(args)
    ids = args[:ids].split(',') if args[:ids]
    if args[:regex]
#      puts Flapjack::Diner.entities_matching(args[:regex])
      # TODO: entities_matching method is not in the Diner gem but is on the project page.
      puts "Regex matching not yet implemented in Diner"
    else
      print_json Flapjack::Diner.entities(*ids)
    end
  end

  def update(args)
    ids  = args[:ids].split(',')
    tags = args[:add_tags].split(',') if args[:add_tags]
    rtags = args[:remove_tags].split(',') if args[:remove_tags]
    contacts = args[:add_contacts].split(',') if args[:add_contacts]
    rcontacts = args[:remove_contacts].split(',') if args[:remove_contacts]

#    Flapjack::Diner.update_entities(*ids, changes)
    # There are no valid update field keys yet, per the flapjack-diner docs.

    # Loop through all of the add/remove arrays, make a call to update each one
    # TODO: Add_tags and remove_tags are failing. This might just be a diner docs fail.
    if tags
      tags.each do |tag|
        Flapjack::Diner.update_entities(*ids, :add_tag => tag)
      end
    end
    if rtags
      rtags.each do |tag|
        Flapjack::Diner.update_entities(*ids, :remove_tag => tag)
      end
    end
    if contacts
      contacts.each do |contact|
        Flapjack::Diner.update_entities(*ids, :add_contact => contact)
      end
    end
    if rcontacts
      rcontacts.each do |contact|
        Flapjack::Diner.update_entities(*ids, :remove_contact => contact)
      end
    end
  end

  def status(args)
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.status_report_entities(*ids)
  end


  def test(args)
    ids = args[:ids].split(',') if args[:ids]
    Flapjack::Diner.create_test_notifications_entities(*ids, :summary => args[:summary])
  end
end
