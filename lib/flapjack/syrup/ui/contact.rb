desc 'contact crud'
long_desc '''
contact crud - bunch of sub commands for contacts
'''
command :contact do |c|
  c.desc 'create a new contact'
  c.long_desc '''
By default, this will create a new e-mail medium attached to the contact.

NOTE: Flapjack creates and maintains a "default" notification rule for all contacts.

You can modify the "blackhole" attributes on this rule, but any other changes will cause a new blank rule to be created.
'''
  c.command :create do |create|
    create.desc 'Unique identifier - generated if omitted'
    create.arg_name 'id'
    create.flag [:id,:i]

    create.desc 'First Name'
    create.arg_name 'firstname'
    create.flag [:firstname, :f]

    create.desc 'Last Name'
    create.arg_name 'lastname'
    create.flag [:lastname, :l]

    create.desc 'Email Address'
    create.arg_name 'email'
    create.flag [:email, :e]

    create.desc 'Notification interval (seconds) for email'
    create.arg_name 'interval'
    create.flag [:interval, :n]

    create.desc 'Rollup threshold for email'
    create.arg_name 'rollup'
    create.flag [:rollupthreshold, :r]

    create.desc 'Time Zone'
    create.arg_name 'timezone'
    create.flag [:timezone, :t]

    create.desc 'Tags (comma separated)'
    create.arg_name 'tags'
    create.flag [:tags, :a]

    create.desc 'Do not automatically create the email medium'
    create.switch [:nomedia], :negatable => false

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
