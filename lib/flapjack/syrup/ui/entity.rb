desc 'entity crud + more'
long_desc '''
entity crud and more - bunch of sub commands for entity manipulation
'''
command :entity do |c|
  c.desc 'create a new entity'
  c.command :create do |create|
    create.action do |global_options,options,args|
      puts "TODO: entity create"
    end
  end
  c.desc 'get an entity'
  c.command :get do |get|
    get.action do |global_options,options,args|
      puts "TODO: entity get"
    end
  end
  c.desc 'update an entity'
  c.command :update do |update|
    update.action do |global_options,options,args|
      puts "TODO: entity update"
    end
  end
  c.desc 'delete an entity'
  c.command :delete do |delete|
    delete.action do |global_options,options,args|
      puts "TODO: entity delete"
    end
  end
end
