# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Syrup::Entity

  def create(args)
    tags = args[:tags].split(',') if args[:tags]
    Flapjack::Diner.create_entities([{
      :id    => args[:id],
      :name  => args[:name],
      :tags  => tags
      }])
  end

  def get(args)
    if args[:ids] and args[:regex]
      Trollop::die "Must provide either a list of IDs or a regular expression, not both"
    end
    ids = args[:ids].split(',') if args[:ids]
    if ids
      puts Flapjack::Diner.entities(*ids)
    elsif args[:regex]
      puts Flapjack::Diner.entities_matching(args[:regex])
    end
  end

  def update(args)
    ids  = args[:ids].split(',')
    tags = args[:tags].split(',') if tags
    changes = {}
    changes[:first_name] = args[:first_name] if args[:first_name]
    changes[:last_name]  = args[:last_name] if args[:last_name]
    changes[:email]      = args[:email] if args[:email]
    changes[:timezone]   = args[:timezone] if args[:timezone_name]
    changes[:tags]       = tags if tags
    Flapjack::Diner.update_entities([*ids], changes) #TODO: Is there a mistake in the API docs?
  end

  def delete(args)
    # FLAPJACK API DOCS SHOW NO DELETE METHOD FOR ENTITIES!
    puts "Not implemented"
  end

  def create_scheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.create_scheduled_maintenances_entities(*ids,
      :start_time => args[:start_time],
      :duration   => args[:duration],
      :summary    => args[:summary]
    )
  end

  def delete_scheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.delete_scheduled_maintenances_entities(*ids,
      :start_time => args[:start_time],
    )
  end

  def start_unscheduled_maintenance(args)
    Flapjack::Diner.create_unscheduled_maintenances_entities(*ids,
      :duration   => args[:duration],
      :summary    => args[:summary]
    )
  end

  def update_unscheduled_maintenance(args)
    Flapjack::Diner.update_unscheduled_maintenances_entities(*ids,
      :end_time   => args[:end_time], # ISO 8601
    )
  end

  def get_maintenance_periods(args)
    if !args[:scheduled] and !args[:unscheduled]
      args[:scheduled] = true
      args[:unscheduled] = true
    end
    if args[:scheduled]
      result1 = get_scheduled_maintenance(args)
    end
    if args[:unscheduled]
      result2 = get_unscheduled_maintenance(args)
    end
    result = result1 + result2
  end

  def get_scheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.scheduled_maintenance_report_entities(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def get_unscheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.unscheduled_maintenance_report_entities(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def status(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.status_report_entities(*ids)
  end

  def outages(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.outage_report_entities(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def downtimes(args)
  ids = args[:ids].split(',')
    Flapjack::Diner.downtime_report_entities(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def test(args)
  ids = args[:ids].split(',')
    Flapjack::Diner.create_test_notifications_entities(*ids,
      :summary => args[:summary]
    )
  end
end
