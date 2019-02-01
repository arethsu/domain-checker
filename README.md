# Domain Checker

This tool checks for available domain names. See code example below. A command line interface is in the works.

```ruby
names = ['example', 'hello', 'summer']
tld = 'se'

# A cooldown value of 1.5 or above is recommended.
# DNS servers will otherwise rate limit the script (and timeout requests).
Finder.new(names, tld, 1.5)
Finder.new(('a'..'z').permutation(3).first(10), tld, 1.5)

# You can pass additional parameters, such as output options
# (default: file and stdout), or a timeout value (default: 10).
Finder.new(names, tld, 1.5, { timeout: 10, to_file: false, to_stdout: true })
```
