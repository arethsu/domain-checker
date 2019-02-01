require 'pp'
require 'awesome_print'
require 'colorize'
require 'logger'
require 'whois'

# sld_queue = IO.readlines('en_words.txt').map(&:chomp)
# sld_queue.select! { |sld| sld =~ /^[a-z][a-zA-Z]{2}$/ }

class Range

  # Maybe not so effective, but is fine for this scenario.
  def permutation(n)
    self.to_a.permutation(n)
  end

end

class Finder

  def initialize(name_queue, tld, cooldown_value, options = {})
    @options = { timeout_value: 10, to_file: true, to_stdout: true }.merge(options)

    raise ArgumentError, 'must output to file or stdout' unless @options[:to_file] || @options[:to_stdout]

    @cooldown_value = cooldown_value
    @client = Whois::Client.new(timeout: @options[:timeout_value])

    @name_queue = name_queue
    @tld = tld.start_with?('.') ? tld[1..-1] : tld
    @available_names = []

    if @options[:to_file]
      @success_file = File.open('success_list.txt', 'w') # available
      @failure_file = File.open('failure_list.txt', 'w') # timeout

      at_exit do

        @success_file.close
        @failure_file.close

      end
    end

    if @options[:to_stdout]
      # Output variables:
      @names_per_row = 10
      @names_on_row = 0
    end

    check_names
  end

  private

  def report_status(name, status)
    if @options[:to_file]
      if status == :available
        @success_file.puts(name)
      elsif status == :timeout
        @failure_file.puts(name)
      end
    end

    print_status(name, status) if @options[:to_stdout]
  end

  def print_status(name, status)
    status_colors = { available: :green, taken: :red, timeout: :yellow }

    if @names_on_row >= @names_per_row
      print "\n"
      @names_on_row = 0
    end

    print "#{name} ".colorize(status_colors[status])
    @names_on_row += 1
  end

  def check_names
    @name_queue.each do |name|
      name = name.join if name.instance_of?(Array)

      begin
        @client.lookup("#{name}.#{@tld}").available? ? report_status(name, :available) : report_status(name, :taken)
      rescue Timeout::Error
        report_status(name, :timeout)
      end
      sleep @cooldown_value
    end
  end

end

# 15600 permutations
# 1 second sleep, 4 hours, every 35th
# 1.5 second sleep, 6 hours, no timeouts observed

Finder.new(('a'..'z').permutation(3), 'se', 1.5)
