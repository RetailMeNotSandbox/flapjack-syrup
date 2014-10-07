# TODO: Decide whether to only support json or to support argument-based create/update as well.

require 'json'
module Syrup::Rule

  def create(args)
    File.open( args[:json], "r" ) do |f|
      json = JSON.load( f )
    end
    Flapjack::Diner.create_notification_rules(args[:contact_id], json)
  end

  def get
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.notification_rules(*ids)
  end

  def update
    ids = args[:ids].split(',')
    File.open( args[:json], "r" ) do |f|
      json = JSON.load( f )
    end
    Flapjack::Diner.update_notification_rules(*ids,json)
    #TODO: How to handle changes to time restrictions?
  end

  def delete
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
