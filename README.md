# TTY::Prompt
[![Gem Version](https://badge.fury.io/rb/tty-prompt.svg)][gem]
[![Build Status](https://secure.travis-ci.org/peter-murach/tty-prompt.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/peter-murach/tty-prompt/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/peter-murach/tty-prompt/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/peter-murach/tty-prompt.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-prompt
[travis]: http://travis-ci.org/peter-murach/tty-prompt
[codeclimate]: https://codeclimate.com/github/peter-murach/tty-prompt
[coverage]: https://coveralls.io/r/peter-murach/tty-prompt
[inchpages]: http://inch-ci.org/github/peter-murach/tty-prompt

> A beautiful and powerful interactive command line prompt.

**TTY::Prompt** provides independent prompt component for [TTY](https://github.com/peter-murach/tty) toolkit.

## Features

* Number of prompt types for gathering user input
* A robust API for getting and validating complex inputs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-prompt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-prompt

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1 ask](#21-ask)
    * [2.1.1 settings](#211-settings)
    * [2.1.2 valid read keywords](#212-valid-read-keywords)
  * [2.2 select](#22-select)
  * [2.3 multi_select](#23-multi_select)
  * [2.4 say](#25-say)
  * [2.5 suggest](#26-suggest)

## 1. Usage

In order to start asking questions on the command line, create prompt:

```ruby
prompt = TTY::Prompt.new
```

and then call `ask` with the question for simple input:

```ruby
prompt.ask('Do you like Ruby?', type: :bool) # => true
```

Asking question with list of options couldn't be easier using `select` like so:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

Also, asking multiple choice questions is a breeze with `multi_select`:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.select("Select drinks?", choices)
# =>
#
# Select drinks? (Use arrow keys, press Space to select and Enter to finish)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

## 2. Interface

### 2.1 ask

In order to ask a basic question with a string answer do:

```ruby
answer = prompt.ask("What is your name?")
```

In order to prompt for more complex input you can use robust API by passing hash of properties or using block:

```ruby
prompt.ask("What is your name?") do |q|
  q.required true
  q.validate /\A\w+\Z/
  q.modify   :capitalize
end
```

#### 2.1.1 settings

Below is a list of the settings that may be used for customizing `ask` method behaviour:

```ruby
char       # turn character based input, otherwise line (default: false)
default    # default value used if none is provided
echo       # turn echo on and off (default: true)
in         # specify range '0-9', '0..9', '0...9' or negative '-1..-9'
mask       # mask characters i.e '****' (default: false)
modify     # apply answer modification :upcase, :downcase, :trim, :chomp etc..
read       # Specifies the type of input such as :bool, :string [see](#211-valid-read-keywords)
required   # If true, value entered must be non-empty (default: false)
validate   # regex, proc against which stdin input is checked
```

Validate setting can take `Regex`, `Proc` like so:

```ruby
prompt.ask('What is your username?') { |q|
  q.validate { |input| input =~ (/^[^\.]+\.[^\.]+/) }
}
```

For example, if we wanted to ask a user for a single digit in given range

```ruby
ask("Provide number in range: 0-9") { |q| q.in('0-9') }
```

#### 2.1.2 valid read keywords

The most common thing to do is to cast the answer to specific type. The `read` property is used for that. By default `:string` answer is assumed but this can be changed using one of the following custom readers:

```ruby
:bool       # true or false for strings such as "Yes", "No"
:char       # first character
:date       # date type
:datetime   # datetime type
:email      # validate answer against email regex
:file       # a File object
:float      # decimal or error if cannot convert
:int        # integer or error if cannot convert
:multiline  # multiple line string
:password   # string with echo turned off
:range      # range type
:regex      # regex expression
:string     # string
:symbol     # symbol
:text       # multiline string
:keypress   # the key pressed
```

For example, if you are interested in range type as answer do the following:

```ruby
ask("Provide range of numbers?", read: :range)
```

### 2.2 select

For asking questions involving list of options use `select` method by passing the question and possible choices:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

You can also provide options through DSL using the `choice` method for single entry and/or `choices` call for more than one choice:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice 'Scorpion'
  menu.choice 'Kano'
  menu.choice 'Jax'
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

By default the choice name is used as return value, but you can provide your custom values:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice 'Scorpion', 1
  menu.choice 'Kano', 2
  menu.choice 'Jax', 3
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

If you wish you can also provide a simple hash to denote choice name and its value like so:

```ruby
choices = {'Scorpion' => 1, 'Kano' => 2, 'Jax' => 3}
prompt.select("Choose your destiny?", choices)
```

To mark particular answer as selected use `default` with index of the option starting from `1`:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.default 3

  menu.choice 'Scorpion', 1
  menu.choice 'Kano', 2
  menu.choice 'Jax', 3
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
#   Scorpion
#   Kano
# ‣ Jax
```

You can configure help message, marker like so

```ruby
choices = %w(Scorpion Kano Jax)
prompt.select("Choose your destiny?", choices, help: "(Bash keyboard)")
# =>
# Choose your destiny? (Bash keyboard)
# ‣ Scorpion
#   Kano
#   Jax
```

### 2.3 multi_select

For asking questions involving multiple selection list use `multi_select` method by passing the question and possible choices:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.select("Select drinks?", choices)
# =>
#
# Select drinks? (Use arrow keys, press Space to select and Enter to finish)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

As a return value, the `multi_select` will always return an array by default populated with the names of the choices. If you wish to return custom values for the available choices do:

```ruby
choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
prompt.select("Select drinks?", choices)

# Provided that vodka and beer have been selected, the function will return
# => [1, 2]
```

Similar to `select` method, you can also provide options through DSL using the `choice` method for single entry and/or `choices` call for more than one choice:

```ruby
prompt.multi_select("Select drinks?") do |menu|
  menu.choice :vodka, {score: 1}
  menu.choice :beer, 2
  menu.choice :wine, 3
  menu.choices whisky: 4, bourbon: 5
end
```

To mark choice(s) as selected use the `default` option with index(s) of the option(s) starting from `1`:

```ruby
prompt.multi_select("Select drinks?") do |menu|
  menu.default 2, 5

  menu.choice :vodka,   {score: 10}
  menu.choice :beer,    {score: 20}
  menu.choice :wine,    {score: 30}
  menu.choice :whisky,  {score: 40}
  menu.choice :bourbon, {score: 50}
end
# =>
# Select drinks? beer, bourbon
#   ⬡ vodka
#   ⬢ beer
#   ⬡ wine
#   ⬡ whisky
# ‣ ⬢ bourbon
```

And when you press enter you will see the following selected:

```ruby
# Select drinks? beer, bourbon
# => [{score: 20}, {score: 50}]
```

### 2.4 say

To simply print message out to stdout use `say` like so:

```ruby
prompt.say(...)          # print message to stdout
```

**TTY::Prompt** provides more specific versions of `say` method to better express intenation behind the message:

```ruby
prompt.confirm      # print message(s) in green
prompt.warn         # print message(s) in yellow
prompt.error        # print message(s) in red
```

### 2.5 suggest

To suggest possible matches for the user input use `suggest` method like so:

```ruby
prompt.suggest('sta', ['stage', 'stash', 'commit', 'branch'])
# =>
# Did you mean one of these?
#         stage
#         stash
```

To cusomize query text presented pass `:single_text` and `:plural_text` options to respectively change the message when one match is found or many.

```ruby
possible = %w(status stage stash commit branch blame)
prompt.suggest('b', possible, indent: 4, single_text: 'Perhaps you meant?')
# =>
# Perhaps you meant?
#     blame
```

## Contributing

1. Fork it ( https://github.com/peter-murach/tty-prompt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Piotr Murach. See LICENSE for further details.
