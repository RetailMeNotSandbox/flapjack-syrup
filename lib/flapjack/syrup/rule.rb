module Flapjack::Syrup::Rule
  def create(args)
    # Split CSV arguments into arrays
    entities       = args[:entities].split(',')       if args[:entities]
    regex_entities = args[:regex_entities].split(',') if args[:regex_entities]
    tags           = args[:tags].split(',')           if args[:tags]
    regex_tags     = args[:regex_tags].split(',')     if args[:regex_tags]
    unknown_media  = args[:unknown_media].split(',')  if args[:unknown_media]
    warning_media  = args[:warning_media].split(',')  if args[:warning_media]
    critical_media = args[:critical_media].split(',') if args[:critical_media]

    # Determine values for blackhole properties
    if args[:unknown_blackhole]
      unknown_blackhole = true
    elsif args[:unknown_active]
      unknown_blackhole = false
    end
    if args[:warning_blackhole]
      warning_blackhole = true
    elsif args[:warning_active]
      warning_blackhole = false
    end
    if args[:critical_blackhole]
      critical_blackhole = true
    elsif args[:critical_active]
      critical_blackhole = false
    end

    # Create the notification rule
    # TODO: Add time restrictions
    Flapjack::Diner.create_contact_notification_rules(args[:id], [{
      :entities           => entities,
      :regex_entities     => regex_entities,
      :tags               => tags,
      :regex_tags         => regex_tags,
      :unknown_media      => unknown_media,
      :warning_media      => warning_media,
      :critical_media     => critical_media,
      :unknown_blackhole  => unknown_blackhole,
      :warning_blackhole  => warning_blackhole,
      :critical_blackhole => critical_blackhole
    }])
  end

  def get(args)
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.notification_rules(*ids)
  end

  def update(args)
    changes = {}
    # Split CSV arguments into arrays
    ids                          = args[:ids].split(',') if args[:ids]
    changes[:entities]           = args[:entities].split(',')       if args[:entities]
    changes[:regex_entities]     = args[:regex_entities].split(',') if args[:regex_entities]
    changes[:tags]               = args[:tags].split(',')           if args[:tags]
    changes[:regex_tags]         = args[:regex_tags].split(',')     if args[:regex_tags]
    changes[:unknown_media]      = args[:unknown_media].split(',')  if args[:unknown_media]
    changes[:warning_media]      = args[:warning_media].split(',')  if args[:warning_media]
    changes[:critical_media]     = args[:critical_media].split(',') if args[:critical_media]

    # Determine values for blackhole properties
    if args[:unknown_blackhole]
      changes[:unknown_blackhole] = true
    elsif args[:unknown_active]
      changes[:unknown_blackhole] = false
    end
    if args[:warning_blackhole]
      changes[:warning_blackhole] = true
    elsif args[:warning_active]
      changes[:warning_blackhole] = false
    end
    if args[:critical_blackhole]
      changes[:critical_blackhole] = true
    elsif args[:critical_active]
      changes[:critical_blackhole] = false
    end

    # Apply the changes
    Flapjack::Diner.update_notification_rules(*ids, changes)
    # TODO: How to handle changes to time restrictions?
  end

  def delete(args)
    ids = args[:ids].split(',') if args[:ids]
    Flapjack::Diner.delete_notification_rules(*ids)
  end
end

# Sample call from API docs, for reference

# Flapjack::Diner.create_contact_notification_rules(
#   '5',
#   {
#     'entities'           => [ 'foo-app-01.example.com' ],
#     'regex_entities'     => [ '^foo-\S{3}-\d{2}.example.com$' ],
#     'tags'               => [ 'database', 'physical' ],
#     'regex_tags'         => nil,
#     'time_restrictions'  => [
#       {
#         'start_time' => '2013-01-28 08:00:00',
#         'end_time'   => '2013-01-28 18:00:00',
#         'rrules'     => [
#           {
#             'validations' => {
#               'day' => [ 1, 2, 3, 4, 5 ]
#               },
#             'rule_type'   => 'Weekly',
#             'interval'    => 1,
#             'week_start'  => 0
#           }
#         ],
#         'exrules'       => [],
#         'rtimes'        => [],
#         'extimes'       => []
#       }
#     ],
#     'unknown_media'      => [],
#     'warning_media'      => [ 'email' ],
#     'critical_media'     => [ 'sms', 'email' ],
#     'unknown_blackhole'  => false,
#     'warning_blackhole'  => false,
#     'critical_blackhole' => false
#   }
# )
