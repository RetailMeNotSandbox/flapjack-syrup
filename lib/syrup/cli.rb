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
    CHECK_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Check Commands **
          syrup check get
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
        banner "\n\rsyrup: Create or manipulate objects in your Flapjack environment.\n\r"
        banner "Available subcommands: (syrup SUB-COMMAND --help for detailed usage information)\n\r"
        banner CONTACT_BANNER
        banner MEDIUM_BANNER
        banner PAGERDUTY_BANNER
        banner RULE_BANNER
        banner ENTITY_BANNER
        banner CHECK_BANNER
        text "Global options:"
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
          opt :json,             "JSON argument file (multiple allowed) - command-line args will take precedence over json data", :type => :string, :multi => true
          opt :id,               "Unique identifier (generated if omitted)", :type => :string
          opt :first_name,       "First name (required)", :type => :string, :required => true
          opt :last_name,        "Last name (required)", :type => :string, :required => true
          opt :email,            "Email address (required)", :type => :string, :required => true
          opt :interval,         "Notification interval for email", :type => :integer, :default => 7200
          opt :rollup_threshold, "Rollup threshold for email", :type => :integer, :default => 0
          opt :no_media,         "Do not automatically create the email address medium"
          opt :timezone,         "Time zone", :type => :string
          opt :tags,             "Tags (comma-separated)", :type => :string
          #TODO: There appears to be no way to set media, rules, or entities
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
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
          opt :ids, "Contact identifiers (comma-separated)", :type => :string
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
          opt :id,               "Parent contact ID", :type => :string
          opt :type,             "Medium type", :type => :string, :required => true
          opt :address,          "Medium address", :type => :string, :required => true
          opt :interval,         "Medium interval", :default => 7200, :type => :integer, :required => true
          opt :rollup_threshold, "Rollup threshold", :default => 0, :type => :integer, :required => true #TODO: Find out what this actually is
        end
      when 'get'
        # TODO: Media ID may change when the data handling code is changed, per http://flapjack.io/docs/1.0/jsonapi/?ruby#get-media
        @action_args = Trollop::options do
          opt :ids, "Media Identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids,              "Media identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
          opt :address,          "New medium address", :type => :string
          opt :interval,         "New medium interval", :type => :string
          opt :rollup_threshold, "New rollup threshold", :type => :string
        end
      when 'delete'
        @action_args = Trollop::options do
          opt :ids, "Media identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
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
          opt :id,          "Parent contact ID", :type => :string
          opt :service_key, "PagerDuty service key", :type => :string
          opt :subdomain,   "PagerDuty subdomain", :type => :string
          opt :username,    "PagerDuty username", :type => :string
          opt :password,    "PagerDuty password", :type => :string
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids,         "Parent contact IDs", :type => :string
          opt :service_key, "PagerDuty service key", :type => :string
          opt :subdomain,   "PagerDuty subdomain", :type => :string
          opt :username,    "PagerDuty username", :type => :string
          opt :password,    "PagerDuty password", :type => :string
        end
      when 'delete'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated)", :type => :string
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
          opt :contact_id,         "Contact to notify", :type => :string
          opt :json,               "JSON file containing rule definitions", :type => :string, :multi => true
          opt :entity,             "Entity (multiple allowed)", :type => :string, :multi => true
          opt :regex_entity,       "Entity regex (multiple allowed)", :type => :string, :multi => true
          opt :tags,               "Tags (comma-separated)", :type => :string
          opt :regex_tag,          "Tag regex (multiple allowed)", :type => :string, :multi => true
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
          opt :ids, "Rule identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
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
          opt :ids, "Rule identifiers (comma-separated)", :type => :string
        end
      else
        explode(opts)
      end
    end


    def entity
      opts = subparser('ENTITY')
      @action = ARGV.shift
      case @action
      when 'get'
        # TODO: Regex not yet implemented in diner. When it is - should these be mutually exclusive?
        @action_args = Trollop::options do
          opt :ids,   "Entity identifiers (comma-separated, or get all if omitted)", :type => :string
#          opt :regex, "Return only entities matching this regular expression", :type => :string
        end
        Trollop::die :ids, "cannot be called with argument --regex" if @action_args[:ids] and @action_args[:regex]
      when 'update'
        @action_args = Trollop::options do
          # TODO: Diner project page says there are no valid update field keys yet.
          opt :ids,             "Entity identifiers (comma-separated, or get all if omitted)", :type => :string
          opt :add_tags,        "Apply tags (comma-separated)", :type => :string
          opt :remove_tags,     "Remove tags (comma-separated)", :type => :string
          opt :add_contacts,    "Add contacts for this entity (comma-separated)", :type => :string
          opt :remove_contacts, "Remove contacts for this entity (comma-separated)", :type => :string
        end
      when 'status'
        @action_args = Trollop::options do
          opt :ids, "Entities to get status for (comma-separated)", :type => :string
        end
      when 'test'
        @action_args = Trollop::options do
          opt :ids,     "Entity to test notifications for (comma-separated)", :type => :string
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
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Check identifiers (comma-separated, or all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids,         "Check identifiers (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :enable,      "Enable the check"
          opt :disable,     "Disable the check"
          opt :add_tags,    "Apply tags (comma-separated)", :type => :string
          opt :remove_tags, "Remove tags (comma-separated)", :type => :string
          #TODO: Why is there "add_contact" and "remove_tag" on this?
        end
      when 'status'
        @action_args = Trollop::options do
          opt :ids, "Checks to get status for (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
        end
      when 'test'
        @action_args = Trollop::options do
          opt :ids,     "Checks to test notifications for (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :summary, "Notification text to send", :type => :string
        end
      else
        explode(opts)
      end
    end
  end
end
