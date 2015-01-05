desc 'medium crud'
long_desc '''
medium crud - bunch of sub commands for medium manipulation
'''
command :medium do |c|
  c.desc 'create a new medium'
  c.command :create do |create|
    create.action do |global_options,options,args|
      puts "TODO: medium create"
    end
  end
  c.desc 'get an madium'
  c.command :get do |get|
    get.action do |global_options,options,args|
      puts "TODO: medium get"
    end
  end
  c.desc 'update an mediu'
  c.command :update do |update|
    update.action do |global_options,options,args|
      puts "TODO: medium update"
    end
  end
  c.desc 'delete an medium'
  c.command :delete do |delete|
    delete.action do |global_options,options,args|
      puts "TODO: medium delete"
    end
  end
end
