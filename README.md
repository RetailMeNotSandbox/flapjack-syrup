# syrup

Syrup is a command-line utility for creating and modifying resources in a Flapjack environment.

## Installation

To use, checkout the repository, navigate to the directory, and then install:

    $ bundle install

## Usage

Syrup is a command-based app, similar to git, and is called with the following general form:

    $ syrup --GLOBALS RESOURCE ACTION --OPTIONS

Global arguments:

    --host, -h <s>:   Host to connect to (default: localhost)
    --port, -p <s>:   Port to connect to (default: 3081)
     --log, -l <s>:   Flapjack API log (default: flapjack_diner.log)
      --pretty, -r:   Pretty-print JSON output
     --version, -v:   Print version and exit
        --help, -e:   Show this message

Available commands are listed below.

### contact create

Create a new contact.

By default, this will create a new e-mail medium attached to the contact.

Example:

    syrup --GLOBALS contact create --first-name FIRST --last-name LAST --email EMAIL

Available options:

                  --id, -i <s>:   Unique identifier (generated if omitted)
          --first-name, -f <s>:   First name (required)
           --last-name, -l <s>:   Last name (required)
               --email, -e <s>:   Email address (required)
            --interval, -n <i>:   Notification interval for email (default: 7200)
    --rollup-threshold, -r <i>:   Rollup threshold for email (default: 0)
            --timezone, -t <s>:   Time zone
                --tags, -a <s>:   Tags (comma-separated)
                --no-media, -o:   Do not automatically create the email medium
                    --help, -h:   Show this message

### contact get

Get JSON contact data.

Specify IDs as comma-separated values, or no IDs to get all contacts.

Example:

    syrup --GLOBALS contact get [--ids FIRST,SECOND,THIRD]

Available options:

    --ids, -i <s>:   Contact identifiers (comma-separated, or get all if omitted)
       --help, -h:   Show this message

### contact update

Modify existing contacts.

Specify IDs as comma-separated values, or no IDs to update all contacts.

Example:

    syrup --GLOBALS contact update [--ids FIRST,SECOND] [--first_name FIRST] [--add_entities ID1,ID2,ID3]

Options:

                --ids, -i <s>:   Contact identifiers (comma-separated)
         --first-name, -f <s>:   First name
          --last-name, -l <s>:   Last name
              --email, -e <s>:   Email address (of the CONTACT, not the notification medium)
           --timezone, -t <s>:   Time zone
               --tags, -a <s>:   Replace all tags on contact (comma-separated)
       --add-entities, -d <s>:   Link to entities (comma-separated)
    --remove-entities, -r <s>:   Unlink from entities (comma-separated)
          --add-rules, -u <s>:   Apply notification rules (comma-separated)
       --remove-rules, -m <s>:   Remove notification rules (comma-separated)
                   --help, -h:   Show this message

### contact delete

Delete contacts.

Specify IDs as comma-separated values.

Example:

    syrup --GLOBALS contact delete --ids FIRST,SECOND,THIRD

Options:

    --ids, -i <s>:   Contact identifiers (comma-separated)
       --help, -h:   Show this message

### medium create

Create a new notification medium for a contact.

Supported media types are `email`, `jabber`, and `sms`. PagerDuty is handled separately - see `pagerduty create` below.

Example:

    syrup --GLOBALS medium create --id CONTACT --type TYPE --address ADDRESS

Options:

                  --id, -i <s>:   Parent contact ID (required)
                --type, -t <s>:   Medium type (required)
             --address, -a <s>:   Medium address (required)
            --interval, -n <i>:   Notification interval (default: 7200)
    --rollup-threshold, -r <i>:   Rollup threshold (default: 0)
                    --help, -h:   Show this message

### medium get

Get JSON medium data.

Specify IDs as comma-separated values, or no IDs to get all media.

Example:

    syrup --GLOBALS medium get [--ids FIRST,SECOND,THIRD]

Options:

    --ids, -i <s>:   Media Identifiers (comma-separated, form "<contactID>_<type>")
       --help, -h:   Show this message

### medium update

Modify existing media.

Specify IDs as comma-separated values, or no IDs to update all media.

Example:

    syrup --GLOBALS medium update [--ids FIRST,SECOND] [--address ADDRESS] [--interval INTERVAL]

Options:

                 --ids, -i <s>:   Media identifiers (comma-separated, form "<contactID>_<type>")
             --address, -a <s>:   New medium address
            --interval, -n <s>:   New medium interval
    --rollup-threshold, -r <s>:   New rollup threshold
                    --help, -h:   Show this message

### medium delete

Delete media.

Specify IDs as comma-separated values.

Example:

    syrup --GLOBALS medium delete --ids FIRST,SECOND,THIRD

Options:

    --ids, -i <s>:   Media identifiers (comma-separated, form "<contactID>_<type>", required)
       --help, -h:   Show this message

### pagerduty create

Give PagerDuty credentials to a contact.

PagerDuty is handled separately from media because it uses its own unique API calls.

Example:

    syrup --GLOBALS pagerduty create --id CONTACT --service-key KEY --username USER --password PASS [--subdomain DOMAIN]

Options:

             --id, -i <s>:   Parent contact ID (required)
    --service-key, -s <s>:   PagerDuty service key (required)
      --subdomain, -u <s>:   PagerDuty subdomain
       --username, -e <s>:   PagerDuty username (required)
       --password, -p <s>:   PagerDuty password (required)
               --help, -h:   Show this message

### pagerduty get

Get JSON pagerduty credentials.

Specify contact IDs as comma-separated values, or no IDs to get all.

Example:

    syrup --GLOBALS pagerduty get [--ids FIRST,SECOND,THIRD]

Options:

    --ids, -i <s>:   Contact identifiers (comma-separated, or get all if omitted)
       --help, -h:   Show this message

### pagerduty update

Modify existing pagerduty credentials.

Specify contact IDs as comma-separated values, or no IDs to update all.

Example:

    syrup --GLOBALS pagerduty update [--ids FIRST,SECOND] [--username USER] [--password PASS]

Options:

            --ids, -i <s>:   Parent contact IDs
    --service-key, -s <s>:   PagerDuty service key
      --subdomain, -u <s>:   PagerDuty subdomain
       --username, -e <s>:   PagerDuty username
       --password, -p <s>:   PagerDuty password
               --help, -h:   Show this message

### pagerduty delete

Delete PagerDuty credentials from a contact.

Specify contact IDs as comma-separated values.

Example:

    syrup --GLOBALS pagerduty delete --ids FIRST,SECOND,THIRD

Options:

    --ids, -i <s>:   Contact identifiers (comma-separated, required)
       --help, -h:   Show this message

### rule create

Create a notification rule.

Notification rules monitor a specific set of entities. This can be defined in any combination of four ways:

  * A list of entity names
  * A regular expression for entity names
  * A list of entity tags
  * A regular expression for entity tags

Each rule has a single contact to notify, and a set of media types to use for each alert type (UNKNOWN, WARNING, CRITICAL).

Notifications can be disabled for an alert type by setting the "blackhole" state on that type.

Example:

    syrup --GLOBALS rule create --id CONTACT [--entities ONE,TWO] [--regex-entities /RX1/,/RX2/] [--critical-media email,jabber]

Options:

                --id, -i <s>:   ID of contact to notify
          --entities, -e <s>:   Entities (comma-separated)
    --regex-entities, -r <s>:   Entity regex (comma-separated)
              --tags, -t <s>:   Tags (comma-separated)
        --regex-tags, -g <s>:   Tag regex (comma-separated)
     --unknown-media, -u <s>:   UNKNOWN notification media types (comma-separated)
     --warning-media, -w <s>:   WARNING notification media types (comma-separated)
    --critical-media, -c <s>:   CRITICAL notification media types (comma-separated)
     --unknown-blackhole, -n:   Flag to ignore UNKNOWN alerts
     --warning-blackhole, -a:   Flag to ignore WARNING alerts
    --critical-blackhole, -l:   Flag to ignore CRITICAL alerts
                  --help, -h:   Show this message

### rule get

Get JSON notification rule data.

Specify IDs as comma-separated values, or no IDs to get all.

Example:

    syrup --GLOBALS rule get [--ids FIRST,SECOND,THIRD]

Options:

    --ids, -i <s>:   Rule identifiers (comma-separated, or get all if omitted)
       --help, -h:   Show this message

### rule update

Modify a notification rule.

Specify IDs as comma-separated values, or no IDs to modify all.

Notification rules monitor a specific set of entities. This can be defined in any combination of four ways:
  * A list of entity names
  * A regular expression for entity names
  * A list of entity tags
  * A regular expression for entity tags

Each rule has a single contact to notify, and a set of media types to use for each alert type (UNKNOWN, WARNING, CRITICAL).

Notifications can be disabled for an alert type by setting the "blackhole" flag, or reactivated with the "active" flag.

Example:

    syrup --GLOBALS rule update [--ids ONE,TWO] [--entities ONE,TWO] [--regex-entities /RX1/,/RX2/] [--critical-media email,jabber] [--unknown-blackhole] [--critical-active]

Options:

               --ids, -i <s>:   Rule IDs to apply changes to
          --entities, -e <s>:   Entity names (comma-separated)
    --regex-entities, -r <s>:   Entity regexes (comma-separated)
              --tags, -t <s>:   Tags (comma-separated)
        --regex-tags, -g <s>:   Tag regexes (comma-separated)
     --unknown-media, -u <s>:   UNKNOWN notification media types (comma-separated)
     --warning-media, -w <s>:   WARNING notification media types (comma-separated)
    --critical-media, -c <s>:   CRITICAL notification media types (comma-separated)
     --unknown-blackhole, -n:   Ignore UNKNOWN alerts
     --warning-blackhole, -a:   Ignore WARNING alerts
    --critical-blackhole, -l:   Ignore CRITICAL alerts
        --unknown-active, -k:   Activate UNKNOWN alerts
        --warning-active, -v:   Activate WARNING alerts
           --critical-active:   Activate CRITICAL alerts
                  --help, -h:   Show this message

### rule delete

Delete a notification rule.

Specify IDs as comma-separated values.

Example:

    syrup --GLOBALS rule delete --ids FIRST,SECOND,THIRD

Options:

    --ids, -i <s>:   Rule identifiers (comma-separated, required)
       --help, -h:   Show this message

### entity get

Get JSON entity data.

Specify IDs as comma-separated values, or no IDs to get all.

Example:

    syrup --GLOBALS entity get [--ids FIRST,SECOND,THIRD]

Options:

    --ids, -i <s>:   Entity identifiers (comma-separated, or get all if omitted)
       --help, -h:   Show this message

### entity update

Modify an entity.

Specify IDs as comma-separated values, or no IDs to modify all.

Example:

    syrup --GLOBALS entity update [--ids ONE,TWO] [--add-tags TAG1,TAG2] [--remove-tags TAG3] [--add-contacts ID1,ID2] [--remove-contacts ID3]

Options:

                --ids, -i <s>:   Entity identifiers (comma-separated, or get all if omitted)
           --add-tags, -a <s>:   Apply tags (comma-separated)
        --remove-tags, -r <s>:   Remove tags (comma-separated)
       --add-contacts, -d <s>:   Add contacts for this entity (comma-separated)
    --remove-contacts, -e <s>:   Remove contacts for this entity (comma-separated)
                   --help, -h:   Show this message

### entity status

Get JSON entity status data.

Specify IDs as comma-separated values, or no IDs to get all.

Entity status includes detailed information on every check linked to that entity ID.

Example:

    syrup --GLOBALS entity status [--ids FIRST,SECOND,THIRD]

Options:

    --ids, -i <s>:   Entities to get status for (comma-separated)
       --help, -h:   Show this message

### entity test

Test notifications for an entity.

Specify IDs as comma-separated values, or no IDs to get all.

Running this command will send a test notification on every check for the entity, in the same way that a real alert would be
applied.

Example:

    syrup --GLOBALS entity test [--ids FIRST,SECOND,THIRD] [--summary 'Testing entities']

Options:

        --ids, -i <s>:   Entities to test notifications for (comma-separated)
    --summary, -s <s>:   Notification text to send
           --help, -h:   Show this message

### check get

Get JSON check data.

Specify IDs as comma-separated values, or no IDs to get all.

Check IDS are a combination of the entity name and check name, separated by a colon.

Example:

    syrup --GLOBALS check get [--ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK]

Options:

    --ids, -i <s>:   Check identifiers (comma-separated, or all if omitted, format "<entity_name>:<check_name>")
       --help, -h:   Show this message

### check update

Modify a check.

Specify IDs as comma-separated values, or no IDs to update all.

Check IDS are a combination of the entity name and check name, separated by a colon.

Example:

    syrup --GLOBALS check update [--ids ENTITY:CHECK,ENTITY:CHECK] [--add_tags TAG,TAG] [--disable]

Options:

            --ids, -i <s>:   Check identifiers (comma-separated, format "<entity_name>:<check_name>")
             --enable, -e:   Enable the check
            --disable, -d:   Disable the check
       --add-tags, -a <s>:   Apply tags (comma-separated)
    --remove-tags, -r <s>:   Remove tags (comma-separated)
               --help, -h:   Show this message

### check status

Get JSON check status data.

Specify IDs as comma-separated values, or no IDs to get all. Check IDS are a combination of the entity name and check name,
separated by a colon.


Example:

    syrup --GLOBALS check status [--ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK]

Options:

    --ids, -i <s>:   Checks to get status for (comma-separated, format "<entity_name>:<check_name>")
       --help, -h:   Show this message

### check test

Test notifications for a check.

Specify IDs as comma-separated values. Check IDS are a combination of the entity name and check name, separated by a colon.

Running this command will send a test notification on the check, in the same way that a real alert would be applied.

Example:

    syrup --GLOBALS check test --ids ENTITY:CHECK,ENTITY:CHECK,ENTITY:CHECK [--summary 'Testing checks']

Options:

        --ids, -i <s>:   Checks to test notifications for (comma-separated, format "<entity_name>:<check_name>")
    --summary, -s <s>:   Notification text to send
           --help, -h:   Show this message

## Contributing

1. Create a ticket on Jira
2. Fork the project into your personal account
3. Create your ticket branch (`git checkout -b ticket-number`)
4. Commit your changes (`git commit -am '[ticket-number] Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request in Stash
