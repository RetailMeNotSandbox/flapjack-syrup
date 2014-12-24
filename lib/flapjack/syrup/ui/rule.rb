desc 'rule crud'
long_desc '''
rule crud - bunch of sub commands for rules manipulation
'''
command :rule do |c|
  c.desc 'create a new rule'
  c.command :create do |create|
    create.action do |global_options,options,args|
      puts "TODO: rule create"
    end
  end
  c.desc 'get an rule'
  c.command :get do |get|
    get.action do |global_options,options,args|
      puts "TODO: rule get"
    end
  end
  c.desc 'update an rule'
  c.command :update do |update|
    update.action do |global_options,options,args|
      puts "TODO: rule update"
    end
  end
  c.desc 'delete an rule'
  c.command :delete do |delete|
    delete.action do |global_options,options,args|
      puts "TODO: rule delete"
    end
  end
end
