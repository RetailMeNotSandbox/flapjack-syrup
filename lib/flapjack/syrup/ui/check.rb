desc 'check commands'
long_desc '''
check commands- bunch of sub commands for check manipulation
'''
command :check do |c|
  c.desc 'Modify a check.'
  c.long_desc '''
Specify IDs as comma-separated values, or no IDs to update all.

Check IDS are a combination of the entity name and check name, separated by a colon.

Example: [--ids ENTITY:CHECK,ENTITY:CHECK]

WARNING: There is no way to re-enable a check via the API once it has been disabled! Flapjack will re-enable it when a new event is received for it.
'''
  c.command :update do |update|
    update.desc "Check identifiers (comma-separated, format '<entity_name>:<check_name>')"
    update.arg_name 'ids'
    update.flag [:ids]
    update.action do |global_options,options,args|
      puts "TODO: check update"
      # Flapjack::Syrup::Check.update(global_options,options,args)
    end
  end
  c.desc 'check status'
  c.command :status do |status|
    status.action do |global_options,options,args|
      puts "TODO: check status"
      # Flapjack::Syrup::Check.status(global_options,options,args)
    end
  end
  c.desc 'test an check'
  c.command :test do |test|
    test.action do |global_options,options,args|
      puts "TODO: check test"
      # Flapjack::Syrup::Check.test(global_options,options,args)
    end
  end
end
