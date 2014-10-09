# Syrup

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

Supported media types are `email`, `jabber`, and `sms`. PagerDuty is handled separately - see [pagerduty create](#pagerduty create) below.

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

### pagerduty get

### pagerduty update

### pagerduty delete

### rule create

### rule get

### rule update

### rule delete

### entity get

### entity update

### entity status

### entity test

### check get

### check update

### check status

### check test

## Contributing

1. Fork it ( https://github.com/[my-github-username]/syrup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
