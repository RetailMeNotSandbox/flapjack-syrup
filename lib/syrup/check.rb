# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Syrup::Check

  # TODO: Determine whether to keep create and update in the codebase.
  # There is NO delete option, so it probably makes more sense to force people to use programmatic methods.
  # Matt suggested that if we dont, we should restructure the CLI:
  # "syrup maintenance [un]scheduled check|entity create|update|delete"


  # def create(args)
  #   tags = args[:tags].split(',') if args[:tags]
  #   Flapjack::Diner.create_checks([{
  #     :entity_id => args[:entity_id],
  #     :name      => args[:name],
  #     :tags      => tags
  #     }])
  # end

  def get(args)
    ids = args[:ids].split(',') if args[:ids]
    puts Flapjack::Diner.checks(*ids)
  end

  # def update(args)
  #   ids  = args[:ids].split(',')
  #   changes = {}
  #   Flapjack::Diner.update_checks([*ids], changes) #TODO: Is there a mistake in the API docs?
  #   # TODO: For-loop applying add_tags and remove_tags
  # end

  def delete(args)
    # FLAPJACK API DOCS SHOW NO DELETE METHOD FOR CHECKS!
    puts "Not implemented"
  end

  def create_scheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.create_scheduled_maintenances_checks(*ids,
      :start_time => args[:start_time],
      :duration   => args[:duration],
      :summary    => args[:summary]
    )
  end

  def delete_scheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.delete_scheduled_maintenances_checks(*ids,
      :start_time => args[:start_time],
    )
  end

  def start_unscheduled_maintenance(args)
    Flapjack::Diner.create_scheduled_maintenances_checks(*ids,
      :duration   => args[:duration],
      :summary    => args[:summary]
    )
  end

  def update_unscheduled_maintenance(args)
    Flapjack::Diner.update_unscheduled_maintenances_checks(*ids,
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
    Flapjack::Diner.scheduled_maintenance_report_checks(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def get_unscheduled_maintenance(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.unscheduled_maintenance_report_checks(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def status(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.status_report_checks(*ids)
  end

  def outages(args)
    ids = args[:ids].split(',')
    Flapjack::Diner.outage_report_checks(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def downtimes(args)
  ids = args[:ids].split(',')
    Flapjack::Diner.downtime_report_checks(*ids,
      :start_time => args[:start_time],
      :end_time   => args[:end_time]
    )
  end

  def test(args)
  ids = args[:ids].split(',')
    Flapjack::Diner.create_test_notifications_checks(*ids,
      :summary => args[:summary]
    )
  end
end
