module Flapjack::Syrup::Check

  # TODO: get() not working - see https://github.com/flapjack/flapjack-diner/issues/38

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
