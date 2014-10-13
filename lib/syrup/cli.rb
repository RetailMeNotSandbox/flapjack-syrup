#!/usr/bin/env ruby

require 'syrup.rb'
require 'trollop'
require 'flapjack-diner'

module SyrupCLI
  # Thanks to agent462 and the Sensu-CLI project for the base CLI design.
  # https://github.com/agent462/sensu-cli

  class Cli
    OBJECTS = %w(contact medium pagerduty rule entity check)

    BASE_COMMANDS        = %w(create get update delete)
    MAINTENANCE_COMMANDS = %w(create-scheduled-maintenance delete-scheduled-maintenance start-unscheduled-maintenance update-unscheduled-maintenance get-maintenance-periods status outages downtimes test)

    CONTACT_COMMANDS     = BASE_COMMANDS
    MEDIUM_COMMANDS      = BASE_COMMANDS
    PAGERDUTY_COMMANDS   = BASE_COMMANDS
    RULE_COMMANDS        = BASE_COMMANDS
    ENTITY_COMMANDS      = %w(create get update).concat(MAINTENANCE_COMMANDS)
    CHECK_COMMANDS       = %w(create update).concat(MAINTENANCE_COMMANDS)

    CONTACT_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Contact Commands **
          syrup contact create
          syrup contact get
          syrup contact update
          syrup contact delete\n\r
        EOS
    MEDIUM_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Medium Commands **
          syrup medium create
          syrup medium get
          syrup medium update
          syrup medium delete\n\r
        EOS
    PAGERDUTY_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** PagerDuty Commands **
          syrup pagerduty create
          syrup pagerduty get
          syrup pagerduty update
          syrup pagerduty delete\n\r
        EOS
    RULE_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Notification Rule Commands **
          syrup rule create
          syrup rule get
          syrup rule update
          syrup rule delete\n\r
        EOS
    ENTITY_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Entity Commands **
          syrup entity get
          syrup entity update
          syrup entity status
          syrup entity test\n\r
        EOS
        # TODO: Re-add 'syrup check get' if it turns out to be a valid option
    CHECK_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Check Commands **
          syrup check update
          syrup check status
          syrup check test\n\r
        EOS

    attr_accessor :global_args
    attr_accessor :object
    attr_accessor :object_args
    attr_accessor :action
    attr_accessor :action_args

    def parse
      @global_parser = Trollop::Parser.new do
#        version "sensu-cli version: #{SensuCli::VERSION}"
        version "\n\rsyrup version #{Syrup::VERSION}"
        banner "\n\rsyrup: Create or manipulate objects in your Flapjack environment.\n\r"
        banner "Available subcommands: (syrup SUB-COMMAND --help for detailed usage information)\n\r"
        banner CONTACT_BANNER
        banner MEDIUM_BANNER
        banner PAGERDUTY_BANNER
        banner RULE_BANNER
        banner ENTITY_BANNER
        banner CHECK_BANNER
        banner "Global options:"
        opt :host, "Host to connect to", :default => "localhost"
        opt :port, "Port to connect to", :default => "3081"
        opt :log, "Flapjack API log", :default => "flapjack_diner.log"
        opt :pretty, "Pretty-print JSON output"
        stop_on OBJECTS
      end

      Trollop::with_standard_exception_handling @global_parser do
        @global_args = @global_parser.parse ARGV
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      end
      @object = ARGV.shift
      self.respond_to?(@object) ? send(@object) : explode(@global_parser)

    end

    def subparser(cli)
      Trollop::Parser.new do
        banner Cli.const_get("#{cli}_BANNER")
        stop_on Cli.const_get("#{cli}_COMMANDS")
      end
    end

    def explode_if_empty(opts, command)
      explode(opts) if ARGV.empty? && command != 'list'
    end

    def explode(opts)
      Trollop::with_standard_exception_handling opts do
        raise Trollop::HelpNeeded # show help screen
      end
    end


    def contact
      opts = subparser('CONTACT')
      @action = ARGV.shift
      case @action
      when 'create'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup contact create: Create a new contact.

            By default, this will create a new e-mail medium attached to the contact.

            NOTE: Flapjack creates and maintains a 'default' notification rule for all contacts. You can modify the 'blackhole' attributes on this rule, but any other changes will cause a new blank rule to be created.

            Example: syrup --GLOBALS contact create --first-name FIRST --last-name LAST --email EMAIL

            Options:
          EOS
          opt :id,               "Unique identifier (generated if omitted)", :type => :string
          opt :first_name,       "First name (required)", :type => :string, :required => true
          opt :last_name,        "Last name (required)", :type => :string, :required => true
          opt :email,            "Email address (required)", :type => :string, :required => true
          opt :interval,         "Notification interval for email", :type => :integer, :default => 7200
          opt :rollup_threshold, "Rollup threshold for email", :type => :integer, :default => 0
          opt :timezone,         "Time zone", :type => :string
          opt :tags,             "Tags (comma-separated)", :type => :string
          opt :no_media,         "Do not automatically create the email medium"
#          opt :no_all_entity,    "Do not add to the ALL entity"
          #TODO: There appears to be no way to set rules or entities on creation
        end
      when 'get'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup contact get: Get JSON contact data.

            Specify IDs as comma-separated values, or no IDs to get all contacts.

            Example: syrup --GLOBALS contact get [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup contact update: Modify existing contacts.

            Specify IDs as comma-separated values, or no IDs to update all contacts.

            Example: syrup --GLOBALS contact update [--ids FIRST,SECOND] [--first_name FIRST] [--add_entities ID1,ID2,ID3]

            Options:
          EOS
          opt :ids,             "Contact identifiers (comma-separated)", :type => :string, :required => true
          opt :first_name,      "First name", :type => :string
          opt :last_name,       "Last name", :type => :string
          opt :email,           "Email address (of the CONTACT, not the notification medium)", :type => :string
          opt :timezone,        "Time zone", :type => :string
          opt :tags,            "Replace all tags on contact (comma-separated)", :type => :string
#          opt :add_tags,        "Apply tags (comma-separated)", :type => :string
#          opt :remove_tags,     "Remove tags (comma-separated)", :type => :string
          opt :add_entities,    "Link to entities (comma-separated)", :type => :string
          opt :remove_entities, "Unlink from entities (comma-separated)", :type => :string
          # TODO: Add support for add_media, remove_media when available
#          opt :add_media,       "Add media (comma-separated) (NOT YET SUPPORTED as of Flapjack 1.0)", :type => :string
#          opt :remove_media,    "Remove media (comma-separated) (NOT YET SUPPORTED as of Flapjack 1.0)", :type => :string
          opt :add_rules,       "Apply notification rules (comma-separated)", :type => :string
          opt :remove_rules,    "Remove notification rules (comma-separated)", :type => :string
        end
      when 'delete'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup contact delete: Delete contacts.

            Specify IDs as comma-separated values.

            Example: syrup --GLOBALS contact delete --ids FIRST,SECOND,THIRD

            Options:
          EOS
          opt :ids, "Contact identifiers (comma-separated)", :type => :string, :required => true
        end
      else
        explode(opts)
      end
    end


    def medium
      opts = subparser('MEDIUM')
      @action = ARGV.shift
      case @action
      when 'create'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup medium create: Create a new notification medium for a contact.

            Supported media types are 'email', 'jabber', and 'sms'. PagerDuty is handled separately - see 'syrup pagerduty --help'.

            Example: syrup --GLOBALS medium create --id CONTACT --type TYPE --address ADDRESS

            Options:
          EOS
          opt :id,               "Parent contact ID (required)", :type => :string, :required => true
          opt :type,             "Medium type (required)", :type => :string, :required => true
          opt :address,          "Medium address (required)", :type => :string, :required => true
          opt :interval,         "Notification interval", :default => 7200, :type => :integer, :required => true
          opt :rollup_threshold, "Rollup threshold", :default => 0, :type => :integer, :required => true #TODO: Find out what this actually is
        end
      when 'get'
        # TODO: Media ID may change when the data handling code is changed, per http://flapjack.io/docs/1.0/jsonapi/?ruby#get-media
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup medium get: Get JSON medium data.

            Specify IDs as comma-separated values, or no IDs to get all media.

            Example: syrup --GLOBALS medium get [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids, "Media Identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup medium update: Modify existing media.

            Specify IDs as comma-separated values, or no IDs to update all media.

            Example: syrup --GLOBALS medium update [--ids FIRST,SECOND] [--address ADDRESS] [--interval INTERVAL]

            Options:
          EOS
          opt :ids,              "Media identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
          opt :address,          "New medium address", :type => :string
          opt :interval,         "New medium interval", :type => :integer
          opt :rollup_threshold, "New rollup threshold", :type => :integer
        end
      when 'delete'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup medium delete: Delete media.

            Specify IDs as comma-separated values.

            Example: syrup --GLOBALS medium delete --ids FIRST,SECOND,THIRD

            Options:
          EOS
          opt :ids, "Media identifiers (comma-separated, form \"<contactID>_<type>\", required)", :type => :string, :required => true
        end
      else
        explode(opts)
      end
    end


    def pagerduty
      opts = subparser('PAGERDUTY')
      @action = ARGV.shift
      case @action
      when 'create'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup pagerduty create: Give PagerDuty credentials to a contact.

            PagerDuty is handled separately from media because it uses its own unique API calls.

            Example: syrup --GLOBALS pagerduty create --id CONTACT --service-key KEY --username USER --password PASS [--subdomain DOMAIN]

            Options:
          EOS
          opt :id,          "Parent contact ID (required)", :type => :string, :required => true
          opt :service_key, "PagerDuty service key (required)", :type => :string, :required => true
          opt :subdomain,   "PagerDuty subdomain", :type => :string
          opt :username,    "PagerDuty username (required)", :type => :string, :required => true
          opt :password,    "PagerDuty password (required)", :type => :string, :required => true
        end
      when 'get'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup pagerduty get: Get JSON pagerduty credentials.

            Specify contact IDs as comma-separated values, or no IDs to get all.

            Example: syrup --GLOBALS pagerduty get [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup pagerduty get: Modify existing pagerduty credentials.

            Specify contact IDs as comma-separated values, or no IDs to update all.

            Example: syrup --GLOBALS pagerduty update [--ids FIRST,SECOND] [--username USER] [--password PASS]

            Options:
          EOS
          opt :ids,         "Parent contact IDs", :type => :string
          opt :service_key, "PagerDuty service key", :type => :string
          opt :subdomain,   "PagerDuty subdomain", :type => :string
          opt :username,    "PagerDuty username", :type => :string
          opt :password,    "PagerDuty password", :type => :string
        end
      when 'delete'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup pagerduty delete: Delete PagerDuty credentials from a contact.

            Specify contact IDs as comma-separated values.

            Example: syrup --GLOBALS pagerduty delete --ids FIRST,SECOND,THIRD

            Options:
          EOS
          opt :ids, "Contact identifiers (comma-separated, required)", :type => :string, :required => true
        end
      else
        explode(opts)
      end
    end


    def rule
      opts = subparser('RULE')
      @action = ARGV.shift
      case @action
      when 'create'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup rule create: Create a notification rule.

            Notification rules monitor a specific set of entities. This can be defined in any combination of four ways:
              * A list of entity names
              * A regular expression for entity names
              * A list of entity tags
              * A regular expression for entity tags

            Each rule has a single contact to notify, and a set of media types to use for each alert type (UNKNOWN, WARNING, CRITICAL).

            Notifications can be disabled for an alert type by setting the "blackhole" state on that type.

            Example: syrup --GLOBALS rule create --id CONTACT [--entities ONE,TWO] [--regex-entities /RX1/,/RX2/] [--critical-media email,jabber]

            Options:
          EOS
          opt :id,                 "ID of contact to notify", :type => :string
#          opt :json,               "JSON file containing rule definitions", :type => :string, :multi => true
          opt :entities,           "Entities (comma-separated)", :type => :string
          opt :regex_entities,     "Entity regex (comma-separated)", :type => :string
          opt :tags,               "Tags (comma-separated)", :type => :string
          opt :regex_tags,         "Tag regex (comma-separated)", :type => :string
#          opt :time_restrictions,  "Time restrictions (NOT IMPLEMENTED - marked as \"TODO\" on the Diner project page.)", :type => :string
#          opt :start_time,         "Start time", :type => :string
#          opt :end_time,           "End time", :type => :string
#          opt :rrules,             "Not implemented"
#          opt :exrules,            "Not implemented"
#          opt :rtimes,             "Not implemented"
#          opt :extimes,            "Not implemented"
          opt :unknown_media,      "UNKNOWN notification media types (comma-separated)", :type => :string
          opt :warning_media,      "WARNING notification media types (comma-separated)", :type => :string
          opt :critical_media,     "CRITICAL notification media types (comma-separated)", :type => :string
          opt :unknown_blackhole,  "Flag to ignore UNKNOWN alerts"
          opt :warning_blackhole,  "Flag to ignore WARNING alerts"
          opt :critical_blackhole, "Flag to ignore CRITICAL alerts"
        end
      when 'get'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup rule get: Get JSON notification rule data.

            Specify IDs as comma-separated values, or no IDs to get all.

            Example: syrup --GLOBALS rule get [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids, "Rule identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup rule update: Modify a notification rule.

            Specify IDs as comma-separated values, or no IDs to modify all.

            Notification rules monitor a specific set of entities. This can be defined in any combination of four ways:
              * A list of entity names
              * A regular expression for entity names
              * A list of entity tags
              * A regular expression for entity tags

            Each rule has a single contact to notify, and a set of media types to use for each alert type (UNKNOWN, WARNING, CRITICAL).

            Notifications can be disabled for an alert type by setting the "blackhole" flag, or reactivated with the "active" flag.

            NOTE: Flapjack creates and maintains a 'default' notification rule for all contacts. You can modify the 'blackhole' attributes on this rule, but any other changes will cause a new blank rule to be created.

            Example: syrup --GLOBALS rule update [--ids ONE,TWO] [--entities ONE,TWO] [--regex-entities /RX1/,/RX2/] [--critical-media email,jabber] [--unknown-blackhole] [--critical-active]

            Options:
          EOS
          # TODO: Verify that these are all full replacement actions, and that there's no add/remove methods
          opt :ids,                "Rule IDs to apply changes to", :type => :string
#          opt :json,               "JSON file containing changes to apply", :type => :string
          opt :entities,           "Entity names (comma-separated)", :type => :string
          opt :regex_entities,     "Entity regexes (comma-separated)", :type => :string
          opt :tags,               "Tags (comma-separated)", :type => :string
          opt :regex_tags,         "Tag regexes (comma-separated)", :type => :string
#          opt :time_restrictions,  "Time restrictions (NOT IMPLEMENTED - marked as \"TODO\" on the Diner project page.)", :type => :string
#          opt :start_time,         "Start time", :type => :string
#          opt :end_time,           "End time", :type => :string
#          opt :rrules,             "Not implemented"
#          opt :exrules,            "Not implemented"
#          opt :rtimes,             "Not implemented"
#          opt :extimes,            "Not implemented"
          opt :unknown_media,      "UNKNOWN notification media types (comma-separated)", :type => :string
          opt :warning_media,      "WARNING notification media types (comma-separated)", :type => :string
          opt :critical_media,     "CRITICAL notification media types (comma-separated)", :type => :string
          opt :unknown_blackhole,  "Ignore UNKNOWN alerts"
          opt :warning_blackhole,  "Ignore WARNING alerts"
          opt :critical_blackhole, "Ignore CRITICAL alerts"
          opt :unknown_active,     "Activate UNKNOWN alerts"
          opt :warning_active,     "Activate WARNING alerts"
          opt :critical_active,    "Activate CRITICAL alerts"
        end
        Trollop::die :unknown_blackhole,  "cannot be called with argument --unknown-active" if @action_args[:unknown_blackhole] and @action_args[:unknown_active]
        Trollop::die :warning_blackhole,  "cannot be called with argument --warning-active" if @action_args[:warning_blackhole] and @action_args[:warning_active]
        Trollop::die :critical_blackhole, "cannot be called with argument --critical-active" if @action_args[:critical_blackhole] and @action_args[:critical_active]
      when 'delete'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup rule delete: Delete a notification rule.

            Specify IDs as comma-separated values.

            Example: syrup --GLOBALS rule delete --ids FIRST,SECOND,THIRD

            Options:
          EOS
          opt :ids, "Rule identifiers (comma-separated, required)", :type => :string, :required => true
        end
      else
        explode(opts)
      end
    end


    def entity
      opts = subparser('ENTITY')
      @action = ARGV.shift
      case @action
      when 'create-ALL'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity create-ALL: Create special 'ALL' entity.

            The 'ALL' entity (ID ALL, name ALL) is a special entity that aggregates all entities.

            To use ALL, attach a user to the entity. Update the user's default notification rule to enable 'blackhole' for all alert types, then add another rule to allow specific checks or entities.

            Example: syrup --GLOBALS entity create-ALL

            Options:
          EOS
        end
      when 'get'
        # TODO: Regex not yet implemented in diner. When it is - should these be mutually exclusive?
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity get: Get JSON entity data.

            Specify IDs as comma-separated values, or no IDs to get all.

            Example: syrup --GLOBALS entity get [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids,   "Entity identifiers (comma-separated, or get all if omitted)", :type => :string
#          opt :regex, "Return only entities matching this regular expression", :type => :string
        end
        Trollop::die :ids, "cannot be called with argument --regex" if @action_args[:ids] and @action_args[:regex]
      when 'update'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity update: Modify an entity.

            Specify IDs as comma-separated values, or no IDs to modify all.

            Example: syrup --GLOBALS entity update [--ids ONE,TWO] [--add-tags TAG1,TAG2] [--remove-tags TAG3] [--add-contacts ID1,ID2] [--remove-contacts ID3]

            Options:
          EOS
          # TODO: Diner project page says there are no valid update field keys yet. Also, says you can add tags but you can't.
          opt :ids,             "Entity identifiers (comma-separated, or get all if omitted)", :type => :string
#          opt :add_tags,        "Apply tags (comma-separated)", :type => :string
#          opt :remove_tags,     "Remove tags (comma-separated)", :type => :string
          opt :add_contacts,    "Add contacts for this entity (comma-separated)", :type => :string
          opt :remove_contacts, "Remove contacts for this entity (comma-separated)", :type => :string
        end
      when 'status'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity status: Get JSON entity status data.

            Specify IDs as comma-separated values, or no IDs to get all.

            Entity status includes detailed information on every check linked to that entity ID.

            Example: syrup --GLOBALS entity status [--ids FIRST,SECOND,THIRD]

            Options:
          EOS
          opt :ids, "Entities to get status for (comma-separated)", :type => :string
        end
      when 'test'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity test: Test notifications for an entity.

            Specify IDs as comma-separated values, or no IDs to get all.

            Running this command will send a test notification on every check for the entity, in the same way that a real alert would be applied.

            Example: syrup --GLOBALS entity test [--ids FIRST,SECOND,THIRD] [--summary 'Testing entities']

            Options:
          EOS
          opt :ids,     "Entities to test notifications for (comma-separated)", :type => :string
          opt :summary, "Notification text to send", :type => :string
        end
      else
        explode(opts)
      end
    end


    def check
      opts = subparser('CHECK')
      @action = ARGV.shift
      case @action
        # TODO: 'get' doesn't actually do anything - see https://github.com/flapjack/flapjack-diner/issues/38
      # when 'get'
      #   @action_args = Trollop::options do
      #     banner <<-EOS.gsub(/^ {12}/, '')
      #       \n\rsyrup check get: Get JSON check data.

      #       Specify IDs as comma-separated values, or no IDs to get all.

      #       Check IDS are a combination of the entity name and check name, separated by a colon.

      #       Example: syrup --GLOBALS check get [--ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK]

      #       Options:
      #     EOS
      #     opt :ids, "Check identifiers (comma-separated, or all if omitted, format \"<entity_name>:<check_name>\")", :type => :string
      #   end
      when 'update'
        @action_args = Trollop::options do
          # TODO: Consider switching this to just be syrup check delete.
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup check update: Modify a check.

            Specify IDs as comma-separated values, or no IDs to update all.

            Check IDS are a combination of the entity name and check name, separated by a colon.

            Example: syrup --GLOBALS check update [--ids ENTITY:CHECK,ENTITY:CHECK] [--add_tags TAG,TAG] [--disable]

            WARNING: There is no way to re-enable a check via the API once it has been disabled! Flapjack will re-enable it when a new event is received for it.

            Options:
          EOS
          opt :ids,         "Check identifiers (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
#          opt :enable,      "Enable the check"
          opt :disable,     "Decommission the check and remove it from the interface and API. Flapjack will re-commission the check if an event is received."
 #         opt :add_tags,    "Apply tags (comma-separated)", :type => :string
#          opt :remove_tags, "Remove tags (comma-separated)", :type => :string
        end
      when 'status'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup check status: Get JSON check status data.

            Specify IDs as comma-separated values, or no IDs to get all. Check IDS are a combination of the entity name and check name, separated by a colon.


            Example: syrup --GLOBALS check status [--ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK]

            Options:
          EOS
          opt :ids, "Checks to get status for (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
        end
      when 'test'
        @action_args = Trollop::options do
          banner <<-EOS.gsub(/^ {12}/, '')
            \n\rsyrup entity test: Test notifications for a check.

            Specify IDs as comma-separated values. Check IDS are a combination of the entity name and check name, separated by a colon.

            Running this command will send a test notification on the check, in the same way that a real alert would be applied.

            Example: syrup --GLOBALS check test --ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK [--summary 'Testing checks']

            Options:
          EOS
          opt :ids,     "Checks to test notifications for (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string, :required => true
          opt :summary, "Notification text to send", :type => :string
        end
      else
        explode(opts)
      end
    end
  end
end
