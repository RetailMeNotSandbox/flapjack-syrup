# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Syrup::Entity

  # TODO: Determine whether to keep create and update in the codebase.
  # There is NO delete option, so it probably makes more sense to force people to use programmatic methods.
  # Matt suggested that if we dont, we should restructure the CLI:
  # "syrup maintenance [un]scheduled check|entity create|update|delete"

  # def create(args)
  #   # Split comma-separated tags into an array
  #   tags = args[:tags].split(',') if args[:tags]
  #   #TODO: Tags failed to be added when I created an entity.
  #   Flapjack::Diner.create_entities([{
  #     # ID is REQUIRED, not auto-generated.
  #     :id    => args[:id],
  #     :name  => args[:name],
  #     :tags  => tags
  #     }])
  # end

  def create(args)
    puts "Not implemented"
  end


  def get(args)
    if args[:ids] and args[:regex]
      Trollop::die "Must provide either a list of IDs or a regular expression, not both"
    end
    ids = args[:ids].split(',') if args[:ids]
    puts Flapjack::Diner.entities
    if ids
      puts Flapjack::Diner.entities(*ids)
    elsif args[:regex]
      puts Flapjack::Diner.entities_matching(args[:regex])
    end
  end

  def update(args)
    ids  = args[:ids].split(',')
    tags = args[:add_tags].split(',') if args[:add_tags]
    rtags = args[:remove_tags].split(',') if args[:remove_tags]
    contacts = args[:add_contacts].split(',') if args[:add_contacts]
    rcontacts = args[:remove_contacts].split(',') if args[:remove_contacts]

#    Flapjack::Diner.update_entities(*ids, changes)
    #TODO: There are no valid update field keys yet, per the flapjack-diner docs.
    #TODO: API docs say IDs should be in an array. Diner docs say sequential arguments.

    # Loop through all of the add/remove arrays, make a call to update each one
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
      rcontacts.each do |contact|
        Flapjack::Diner.update_entities(*ids, :add_contact => tag)
      end
    end
    if rcontacts
      rcontacts.each do |contacts|
        Flapjack::Diner.update_entities(*ids, :remove_contact => tag)
      end
    end
  end

  def delete(args)
    # FLAPJACK API DOCS SHOW NO DELETE METHOD FOR ENTITIES!
    puts "Not implemented"
  end

  # def create_scheduled_maintenance(args)
  #   ids = args[:ids].split(',')
  #   Flapjack::Diner.create_scheduled_maintenances_entities(*ids,
  #     :start_time => args[:start_time],
  #     :duration   => args[:duration],
  #     :summary    => args[:summary]
  #   )
  # end

  def create_scheduled_maintenance(args)
    puts "Not implemented"
  end

  # def delete_scheduled_maintenance(args)
  #   ids = args[:ids].split(',')
  #   Flapjack::Diner.delete_scheduled_maintenances_entities(*ids,
  #     :start_time => args[:start_time],
  #   )
  # end

  def delete_scheduled_maintenance(args)
    puts "Not implemented"
  end

  # def start_unscheduled_maintenance(args)
  #   Flapjack::Diner.create_unscheduled_maintenances_entities(*ids,
  #     :duration   => args[:duration],
  #     :summary    => args[:summary]
  #   )
  # end

  def start_unscheduled_maintenance(args)
    puts "Not implemented"
  end

  # def update_unscheduled_maintenance(args)
  #   Flapjack::Diner.update_unscheduled_maintenances_entities(*ids,
  #     :end_time   => args[:end_time], # ISO 8601
  #   )
  # end

  def update_unscheduled_maintenance(args)
    puts "Not implemented"
  end

  # def get_maintenance_periods(args)
  #   if !args[:scheduled] and !args[:unscheduled]
  #     args[:scheduled] = true
  #     args[:unscheduled] = true
  #   end
  #   if args[:scheduled]
  #     result1 = get_scheduled_maintenance(args)
  #   end
  #   if args[:unscheduled]
  #     result2 = get_unscheduled_maintenance(args)
  #   end
  #   result = result1 + result2
  # end

  def get_maintenance_periods(args)
    puts "Not implemented"
  end

  # def get_scheduled_maintenance(args)
  #   ids = args[:ids].split(',')
  #   Flapjack::Diner.scheduled_maintenance_report_entities(*ids,
  #     :start_time => args[:start_time],
  #     :end_time   => args[:end_time]
  #   )
  # end

  def get_scheduled_maintenance(args)
    puts "Not implemented"
  end

  # def get_unscheduled_maintenance(args)
  #   ids = args[:ids].split(',')
  #   Flapjack::Diner.unscheduled_maintenance_report_entities(*ids,
  #     :start_time => args[:start_time],
  #     :end_time   => args[:end_time]
  #   )
  # end

  def get_unscheduled_maintenance(args)
    puts "Not implemented"
  end

  def status(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.status_report_entities(*ids)
  end

  # def outages(args)
  #   ids = args[:ids].split(',')
  #   Flapjack::Diner.outage_report_entities(*ids,
  #     :start_time => args[:start_time],
  #     :end_time   => args[:end_time]
  #   )
  # end

  def outages(args)
    puts "Not implemented"
  end

  # def downtimes(args)
  # ids = args[:ids].split(',')
  #   Flapjack::Diner.downtime_report_entities(*ids,
  #     :start_time => args[:start_time],
  #     :end_time   => args[:end_time]
  #   )
  # end

  def downtimes(args)
    puts "Not implemented"
  end

  def test(args)
  ids = args[:ids].split(',')
    Flapjack::Diner.create_test_notifications_entities(*ids,
      :summary => args[:summary]
    )
  end
end
