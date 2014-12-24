desc 'pagerduty crud'
long_desc '''
pagerduty crud - bunch of sub commands for pagerduty manipulation
'''
command :pagerduty do |c|
  c.desc 'create a new pagerduty'
  c.command :create do |create|
    create.action do |global_options,options,args|
      puts "TODO: pagerduty create"
    end
  end
  c.desc 'get an pagerduty'
  c.command :get do |get|
    get.action do |global_options,options,args|
      puts "TODO: pagerduty get"
    end
  end
  c.desc 'update an pagerduty'
  c.command :update do |update|
    update.action do |global_options,options,args|
      puts "TODO: pagerduty update"
    end
  end
  c.desc 'delete an pagerduty'
  c.command :delete do |delete|
    delete.action do |global_options,options,args|
      puts "TODO: pagerduty delete"
    end
  end
end
