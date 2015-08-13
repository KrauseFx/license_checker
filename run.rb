require 'open-uri'
require 'json'

class License
  def start(path)
    results = {}
    content = File.read(path)
    content.split("\n").each do |raw|
      current = raw.strip
      matched = current.match(/(.*)\s.*\s([\d\.]*).*/)
      if (matched || []).length > 2
        gem_name = matched[1]
        version = matched[2]

        unless results[gem_name]
          begin
            response = JSON.parse(open("https://rubygems.org/api/v1/gems/#{gem_name}.json").read)
            results[gem_name] = response['licenses']
            puts "Success: '#{gem_name}': '#{results[gem_name]}'"
          rescue => ex
            puts "error parsing #{gem_name}"
          end
        end
      else
        puts "Couldn't match '#{current}'"
      end
    end

    results
  end
end

results = License.new.start("Gemfile.lock")
reversed = {}
results.each do |k, v|
  if v
    v.each do |l|
      reversed[l] ||= []
      reversed[l] << k
    end
  else
    reversed[nil] ||= []
    reversed[nil] << k
  end
end
require 'pry'; binding.pry
