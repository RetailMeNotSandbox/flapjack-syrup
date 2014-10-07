
module Syrup::Tools

  def print_json(data)
    if @cli.global_args[:pretty]
      puts JSON.pretty_generate(data)
    else
      puts data
    end
  end

end