#!/usr/bin/env ruby

require 'optparse'
require 'methadone'
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
          syrup notification-rule create
          syrup notification-rule get
          syrup notification-rule update
          syrup notification-rule delete\n\r
        EOS
    ENTITY_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Entity Commands **
          syrup entity create
          syrup entity get
          syrup entity update
          syrup entity create-scheduled-maintenance
          syrup entity delete-scheduled-maintenance
          syrup entity start-unscheduled-maintenance
          syrup entity update-unscheduled-maintenance
          syrup entity get-maintenance-periods
          syrup entity status
          syrup entity outages
          syrup entity downtimes
          syrup entity test\n\r
        EOS
    CHECK_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Check Commands **
          syrup check create
          syrup check update
          syrup check create-scheduled-maintenance
          syrup check delete-scheduled-maintenance
          syrup check start-unscheduled-maintenance
          syrup check update-unscheduled-maintenance
          syrup check get-maintenance-periods
          syrup check status
          syrup check outages
          syrup check downtimes
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
          opt :id, "Unique identifier (generated if omitted)", :type => :string
          opt :first_name, "First name (required)", :type => :string, :required => true
          opt :last_name, "Last name (required)", :type => :string, :required => true
          opt :email, "Email address (required)", :type => :string, :required => true
          opt :timezone, "Time zone", :type => :string
          opt :tags, "Tags (comma-separated)", :type => :string
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated)", :type => :string
          opt :first_name, "First name", :type => :string
          opt :last_name, "Last name", :type => :string
          opt :email, "Email address", :type => :string
          opt :timezone, "Time zone", :type => :string
          opt :add_tags, "Apply tags (comma-separated)", :type => :string
          opt :remove_tags, "Remove tags (comma-separated)", :type => :string
          # TODO: Add support for add_media, remove_media when available
          opt :add_media, "Add media (comma-separated) (NOT YET SUPPORTED as of Flapjack 1.0)", :type => :string
          opt :remove_media, "Remove media (comma-separated) (NOT YET SUPPORTED as of Flapjack 1.0)", :type => :string
          opt :add_rules, "Apply notification rules to this contact (comma-separated)", :type => :string
          opt :remove_rules, "Remove notification rules from this contact (comma-separated)", :type => :string
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
          opt :id, "Parent Contact ID", :type => :string
          opt :type, "Medium Type", :type => :string, :required => true
          opt :address, "Medium Address", :type => :string, :required => true
          opt :interval, "Medium Interval", :type => :integer, :required => true
          opt :rollup_threshold, "Rollup Threshold", :type => :integer, :required => true #TODO: Find out what this actually is
        end
      when 'get'
        # TODO: Media ID may change when the data handling code is changed, per http://flapjack.io/docs/1.0/jsonapi/?ruby#get-media
        @action_args = Trollop::options do
          opt :ids, "Media Identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids, "Media identifiers (comma-separated, form \"<contactID>_<type>\")", :type => :string
          opt :address, "New medium address", :type => :string
          opt :interval, "New medium interval", :type => :string
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
          opt :id, "Parent contact ID", :type => :string
          opt :service_key, "PagerDuty service key", :type => :string
          opt :subdomain, "PagerDuty subdomain", :type => :string
          opt :username, "PagerDuty username", :type => :string
          opt :password, "PagerDuty password", :type => :string
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Contact identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids, "Parent contact IDs", :type => :string
          opt :service_key, "PagerDuty service key", :type => :string
          opt :subdomain, "PagerDuty subdomain", :type => :string
          opt :username, "PagerDuty username", :type => :string
          opt :password, "PagerDuty password", :type => :string
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
          opt :contact_id, "Contact to notify", :type => :string
          opt :json, "JSON file containing rule definitions", :type => :string, :multi => true
          opt :entity, "Entity (multiple allowed)", :type => :string, :multi => true
          opt :regex_entity, "Entity regex (multiple allowed)", :type => :string, :multi => true
          opt :tags, "Tags (comma-separated)", :type => :string
          opt :regex_tag, "Tag regex (multiple allowed)", :type => :string, :multi => true
          opt :time_restrictions, "Time restrictions (NOT IMPLEMENTED - marked as \"TODO\" on the Diner project page.", :type => :string
#          opt :start_time, "Start time", :type => :string
#          opt :end_time, "End time", :type => :string
#          opt :rrules, "Not implemented"
#          opt :exrules, "Not implemented"
#          opt :rtimes, "Not implemented"
#          opt :extimes, "Not implemented"
          opt :unknown_media, "UNKNOWN notification media types (comma-separated)", :type => :string
          opt :warning_media, "WARNING notification media types (comma-separated)", :type => :string
          opt :critical_media, "CRITICAL notification media types (comma-separated)", :type => :string
          opt :unknown_blackhole, "Ignore UNKNOWN alerts if true"
          opt :warning_blackhole, "Ignore WARNING alerts if true"
          opt :critical_blackhole, "Ignore CRITICAL alerts if true"
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Rule identifiers (comma-separated, or get all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          # TODO: Verify that these are all full replacement actions, and that there's no add/remove methods
          opt :ids, "Rule IDs to apply changes to"
          opt :json, "JSON file containing changes to apply", type => :string, :multi => true
          opt :entity, "Entity (multiple allowed)", :type => :string, :multi => true
          opt :regex_entity, "Entity regex (multiple allowed)", :type => :string, :multi => true
          opt :tags, "Tags (comma-separated)", :type => :string
          opt :regex_tag, "Tag regex (multiple allowed)", :type => :string, :multi => true
          opt :time_restrictions, "Time restrictions (NOT IMPLEMENTED - marked as \"TODO\" on the Diner project page.", :type => :string
#          opt :start_time, "Start time", :type => :string
#          opt :end_time, "End time", :type => :string
#          opt :rrules, "Not implemented"
#          opt :exrules, "Not implemented"
#          opt :rtimes, "Not implemented"
#          opt :extimes, "Not implemented"
          opt :unknown_media, "UNKNOWN notification media types (comma-separated)", :type => :string
          opt :warning_media, "WARNING notification media types (comma-separated)", :type => :string
          opt :critical_media, "CRITICAL notification media types (comma-separated)", :type => :string
          opt :unknown_blackhole, "Ignore UNKNOWN alerts if true"
          opt :warning_blackhole, "Ignore WARNING alerts if true"
          opt :critical_blackhole, "Ignore CRITICAL alerts if true"
        end
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
      when 'create'
        @action_args = Trollop::options do
          opt :id, "Unique Identifier (generated if omitted)", :type => :string
          opt :name, "Entity Name", :type => :string
          opt :tags, "Tags (comma-separated)", :type => :string
#          opt :contacts, "Contact IDs (comma-separated)", :type => :string
          # TODO: Look at the contacts option, can we do this?
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Entity identifiers (comma-separated, or get all if omitted)", :type => :string
          opt :regex, "Return only entities matching this regular expression", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          # TODO: Diner project page says there are no valid update field keys yet.
          opt :add_tags, "Apply tags (comma-separated)", :type => :string
          opt :remove_tags, "Remove tags (comma-separated)", :type => :string
          opt :add_contacts, "Add contacts for this entity (comma-separated)", :type => :string
          opt :remove_contacts, "Remove contacts for this entity (comma-separated)", :type => :string
        end
      when 'create-scheduled-maintenance'
        @action_args = Trollop::options do
          opt :ids, "Entities to place into maintenance (comma-separated)", :type => :string
          opt :start_time, "Start time (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)", :type => :string
          opt :duration, "Maintenance duration (seconds)", :type => :integer
          opt :summary, "Reason for the maintenance period", :type => :string
        end
      when 'delete-scheduled-maintenance'
        @action_args = Trollop::options do
          opt :ids, "Entities to remove the maintenance period from (comma-separated)", :type => :string
          opt :start_time, "Start time of maintenance period to remove (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)", :type => :string
        end
      when 'start-unscheduled-maintenance'
        # TODO: Add a note that this will automatically ACK any failing checks on the entity.
        @action_args = Trollop::options do
          opt :ids, "Entities to place into maintenance (comma-separated)", :type => :string
          opt :duration, "Maintenance duration (seconds)", :type => :integer
          opt :summary, "Reason for the maintenance period", :type => :string
        end
      when 'update-unscheduled-maintenance'
        # TODO: Add a note explaining that CREATION of unscheduled maintenance uses duration; UPDATING it uses a specific time.
        @action_args = Trollop::options do
          opt :ids, "Entities to modify maintenance on (comma-separated)", :type => :string
          opt :end_time, "Maintenance end time (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'get-maintenance-periods'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Entities to get maintenance periods for (comma-separated)"
          opt :scheduled, "Get only scheduled periods"
          opt :unscheduled, "Get only unscheduled periods"
          opt :start_time, "Get periods after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get periods before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'status'
        @action_args = Trollop::options do
          opt :ids, "Entities to get status for (comma-separated)"
        end
      when 'outages'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Entities to get outages for (comma-separated)"
          opt :start_time, "Get outages after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get outages before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'downtimes'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Entities to get downtimes for (comma-separated)"
          opt :start_time, "Get downtimes after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get downtimes before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'test'
        @action_args = Trollop::options do
          opt :ids, "Entity to test notifications for (comma-separated)"
          opt :summary, "Notification text to send"
        end
      else
        explode(opts)
      end
    end


    def check
      opts = subparser('CHECK')
      @action = ARGV.shift
      case @action
      when 'create'
        @action_args = Trollop::options do
          opt :id, "Entity ID", :type => :string
          opt :name, "Check name", :type => :string
          opt :tags, "Tags (comma-separated)", :type => :string
        end
      when 'get'
        @action_args = Trollop::options do
          opt :ids, "Check identifiers (comma-separated, or all if omitted)", :type => :string
        end
      when 'update'
        @action_args = Trollop::options do
          opt :ids, "Check identifiers (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :enable, "Enable the check"
          opt :disable, "Disable the check"
          opt :add_tags, "Apply tags (comma-separated)", :type => :string
          opt :remove_tags, "Remove tags (comma-separated)", :type => :string
          #TODO: Why is there "add_contact" and "remove_tag" on this?
        end
      when 'create-scheduled-maintenance'
        @action_args = Trollop::options do
          opt :ids, "Checks to place into maintenance (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :start_time, "Start time (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)", :type => :string
          opt :duration, "Maintenance duration (seconds)", :type => :integer
          opt :summary, "Reason for the maintenance period", :type => :string
        end
      when 'delete-scheduled-maintenance'
          opt :ids, "Checks to remove the maintenance period from (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :start_time, "Start time of maintenance period to remove (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)", :type => :string
        @action_args = Trollop::options do
        end
      when 'start-unscheduled-maintenance'
        # TODO: Add a note that this will automatically ACK any failing checks passed.
        @action_args = Trollop::options do
          opt :ids, "Checks to place into maintenance (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :duration, "Maintenance duration (seconds)", :type => :integer
          opt :summary, "Reason for the maintenance period", :type => :string
        end
      when 'update-unscheduled-maintenance'
        # TODO: Add a note explaining that CREATION of unscheduled maintenance uses duration; UPDATING it uses a specific time.
        # TODO: Can you change the summary on an unscheduled maintenance object?
        @action_args = Trollop::options do
          opt :ids, "Check to modify maintenance on (comma-separated, format \"<entity_name>:<check_name>\")", :type => :string
          opt :end_time, "Maintenance end time (ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'get-maintenance-periods'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Checks to get maintenance periods for (comma-separated, format \"<entity_name>:<check_name>\")"
          opt :scheduled, "Get only scheduled periods"
          opt :unscheduled, "Get only unscheduled periods"
          opt :start_time, "Get periods after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get periods before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'status'
        @action_args = Trollop::options do
          opt :ids, "Checks to get status for (comma-separated, format \"<entity_name>:<check_name>\")"
        end
      when 'outages'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Checks to get outages for (comma-separated, format \"<entity_name>:<check_name>\")"
          opt :start_time, "Get outages after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get outages before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'downtimes'
        # TODO: Verify that we can actually pass start and end times - shown in the api docs, not shown in the diner project page
        @action_args = Trollop::options do
          opt :ids, "Checks to get downtimes for (comma-separated, format \"<entity_name>:<check_name>\")"
          opt :start_time, "Get downtimes after this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
          opt :end_time, "Get downtimes before this time (optional, ISO 8601 format: YYYY-MM-DDThh:mm:ssZ)"
        end
      when 'test'
        @action_args = Trollop::options do
          opt :ids, "Checks to test notifications for (comma-separated, format \"<entity_name>:<check_name>\")"
          opt :summary, "Notification text to send"
        end
      else
        explode(opts)
      end
    end
  end
end
