# Syrup

Syrup is a command-line utility for creating and modifying resources in a Flapjack environment.

## Installation

To use, checkout the repository, navigate to the directory, and then install:

    $ bundle install

## Usage

Syrup is a command-based app, similar to git, and is called with the following general form:

    $ syrup --global_args RESOURCE ACTION --args

Global arguments:

    --host, -h <s>:   Host to connect to (default: localhost)
    --port, -p <s>:   Port to connect to (default: 3081)
     --log, -l <s>:   Flapjack API log (default: flapjack_diner.log)
      --pretty, -r:   Pretty-print JSON output
     --version, -v:   Print version and exit
        --help, -e:   Show this message



Available commands are listed below.

### contact create

### contact get

### contact update

### contact delete

### medium create

### medium get

### medium update

### medium delete

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
