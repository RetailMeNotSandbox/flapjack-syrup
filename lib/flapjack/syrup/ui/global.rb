# global flags and switches and arguments
#
desc          'Flapjack API Endpoint to connect to.'
default_value 'localhost'
arg_name      'host'
flag          [:h,:host]


desc          'Flapjack API Port to connect to.'
default_value '3081'
arg_name      'port'
flag          [:p,:port]

desc          'Flapjack API log'
default_value 'flapjack_diner.log'
arg_name      'log'
flag          [:l,:log]

desc          'Pretty-Print JSON output'
switch        [:pretty, :r],
  :negatable      => false,
  :default_value  => false
