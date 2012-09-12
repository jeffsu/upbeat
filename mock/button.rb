require 'sinatra'
require 'haml'
require 'uri'
require 'net/http'

get '/' do
  if btn = params[:button]
     Net::HTTP.post_form(URI.parse('http://localhost:3000/stats/buttons'), { btn => 1 })
  end

  haml <<END
%button(onclick="location.href='/?button=one'") One
%button(onclick="location.href='/?button=two'") Two
%button(onclick="location.href='/?button=three'") Three
END


end
