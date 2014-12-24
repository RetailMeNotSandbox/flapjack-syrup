desc 'contact crud'
long_desc '''
contact crud - bunch of sub commands for contacts
'''
command :contact do |c|
  c.desc 'create a new contact'
  c.command :create do |create|
    create.action do |global_options,options,args|
      puts "TODO: contact create"
    end
  end
  c.desc 'get an contact'
  c.command :get do |get|
    get.action do |global_options,options,args|
      puts "TODO: contact get"
    end
  end
  c.desc 'update an contact'
  c.command :update do |update|
    update.action do |global_options,options,args|
      puts "TODO: contact update"
    end
  end
  c.desc 'delete an contact'
  c.command :delete do |delete|
    delete.action do |global_options,options,args|
      puts "TODO: contact delete"
    end
  end
end
