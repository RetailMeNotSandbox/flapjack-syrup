
module Flapjack::Syrup::Tools

  def print_json(data)
    if data and @cli.global_args[:pretty]
      puts JSON.pretty_generate(data)
    elsif data
      puts JSON.generate(data)
    else
      puts ""
    end
  end

end