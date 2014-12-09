# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Flapjack::Syrup::Entity

  def create_ALL()
    # Recreating the entity will remove all of the contact links against it.
    unless Flapjack::Diner.entities('ALL')
      Flapjack::Diner.create_entities([{
        :id   => 'ALL',
        :name => 'ALL'
      }])
    end
  end

  def get(args)
    ids = args[:ids].split(',') if args[:ids]
    # TODO: entities_matching method is not in the Diner gem but is on the project page.
    print_json Flapjack::Diner.entities(*ids)
  end

  def update(args)
    ids  = args[:ids].split(',')
    contacts = args[:add_contacts].split(',') if args[:add_contacts]
    rcontacts = args[:remove_contacts].split(',') if args[:remove_contacts]

    # TODO: There are no valid update field keys yet, per the flapjack-diner docs.

    # Loop through all of the add/remove arrays, make a call to update each one
    # TODO: Add_tags and remove_tags are in the docs but don't work.
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
    puts Flapjack::Diner.create_test_notifications_entities(*ids, :summary => args[:summary])
  end
end
