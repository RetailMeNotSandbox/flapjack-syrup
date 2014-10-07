# TODO: Heavily copypasted, needs to be modified to match the CLI.

module Syrup::Check

  # TODO: Determine whether to keep create and update in the codebase.
  # There is NO delete option, so it probably makes more sense to force people to use programmatic methods.
  # Matt suggested that if we dont, we should restructure the CLI:
  # "syrup maintenance [un]scheduled check|entity create|update|delete"

  def get(args)
    puts Flapjack::Diner.checks
    ids = args[:ids].split(',') if args[:ids]
    puts Flapjack::Diner.checks(*ids)
  end

  def update(args)
    ids   = args[:ids].split(',')
    tags  = args[:add_tags].split(',') if args[:add_tags]
    rtags = args[:remove_tags].split(',') if args[:remove_tags]
    changes = {}
    changes [:enabled] = true  if args[:enable]
    changes [:enabled] = false if args[:disable]
    Flapjack::Diner.update_checks(*ids, changes)

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
  end

  def status(args)
    ids = args[:ids].split(',') if args[:ids]
    print_json Flapjack::Diner.status_report_checks(*ids)
  end

  def test(args)
    ids = args[:ids].split(',') if args[:ids]
    Flapjack::Diner.create_test_notifications_checks(*ids, :summary => args[:summary])
  end

end
