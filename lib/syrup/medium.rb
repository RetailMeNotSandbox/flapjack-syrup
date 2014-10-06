# FEATURE-COMPLETE - needs testing

module Syrup::Medium

  def create(args)
    # Create the medium - no formatting or modification required.
    Flapjack::Diner.create_contact_media(args[:id], [{
      :type             => args[:type],
      :address          => args[:address],
      :interval         => args[:interval],
      :rollup_threshold => args[:rollup_threshold],
    }])
  end

  def get(args)
    # TODO: Media ID may change when the data handling code is changed, per http://flapjack.io/docs/1.0/jsonapi/?ruby#get-media
    # Split comma-separated IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    puts Flapjack::Diner.media(*ids)
  end

  def update(args)
    # Split comma-separated medium IDs into an array
    ids = args[:ids].split(',')
    # Collect all the changes into a hash, and omit fields that aren't changing
    changes = {}
    changes[:address]          = args[:address] if args[:address]
    changes[:interval]         = args[:interval] if args[:interval]
    changes[:rollup_threshold] = args[:rollup_threshold] if args[:rollup_threshold]
    # Apply the changes
    Flapjack::Diner.update_media(*ids, changes)
  end

  def delete(args)
    # Split comma-separated medium IDs into an array
    ids = args[:ids].split(',') if args[:ids]
    # Delete the media
    Flapjack::Diner.delete_media(*ids)
  end
end
