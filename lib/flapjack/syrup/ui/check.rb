desc 'check commands'
long_desc '''
check commands- bunch of sub commands for check manipulation
'''
command :check do |c|
  c.desc 'update an check'
  c.command :update do |update|
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
