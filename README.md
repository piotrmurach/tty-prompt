<div align="center">
  <a href="https://ttytoolkit.org"><img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="TTY Toolkit logo" /></a>
</div>

# TTY::Prompt

[![Gem Version](https://badge.fury.io/rb/tty-prompt.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/tty-prompt/actions/workflows/ci.yml/badge.svg)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/4cguoiah5dprbq7n?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-prompt/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-prompt/badge.svg)][coverage]

[gem]: http://badge.fury.io/rb/tty-prompt
[gh_actions_ci]: https://github.com/piotrmurach/tty-prompt/actions/workflows/ci.yml
[travis]: http://travis-ci.org/piotrmurach/tty-prompt
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-prompt
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-prompt
[coverage]: https://coveralls.io/github/piotrmurach/tty-prompt

> A beautiful and powerful interactive command line prompt.

**TTY::Prompt** provides independent prompt component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Features

* Number of prompt types for gathering user input
* A robust API for validating complex inputs
* User friendly error feedback
* Intuitive DSL for creating complex menus
* Ability to page long menus
* Support for Linux, OS X, FreeBSD and Windows systems

## Windows support

`tty-prompt` works across all Unix and Windows systems in the "best possible" way. On Windows, it uses Win32 API in place of terminal device to provide matching functionality.

Since Unix terminals provide richer set of features than Windows PowerShell consoles, expect to have a better experience on Unix-like platform.

Some features like `select` or `multi_select` menus may not work on Windows when run from Git Bash. See GitHub suggested [fixes](https://github.com/git-for-windows/git/wiki/FAQ#some-native-console-programs-dont-work-when-run-from-git-bash-how-to-fix-it).

For Windows, consider installing [ConEmu](https://conemu.github.io/), [cmder](http://cmder.net/) or [PowerCmd](http://www.powercmd.com/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tty-prompt"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-prompt

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1 ask](#21-ask)
    * [2.1.1 :convert](#211-convert)
    * [2.1.2 :default](#212-default)
    * [2.1.3 :value](#213-value)
    * [2.1.4 :echo](#214-echo)
    * [2.1.5 error messages](#215-error-messages)
    * [2.1.6 :in](#216-in)
    * [2.1.7 :modify](#217-modify)
    * [2.1.8 :required](#218-required)
    * [2.1.9 :validate](#219-validate)
  * [2.2 keypress](#22-keypress)
    * [2.2.1 :timeout](#221-timeout)
  * [2.3 multiline](#23-multiline)
  * [2.4 mask](#24-mask)
  * [2.5 yes?/no?](#25-yesno)
  * [2.6 menu](#26-menu)
    * [2.6.1 choices](#261-choices)
    * [2.6.1.1 :disabled](#2611-disabled)
    * [2.6.2 select](#262-select)
      * [2.6.2.1 :cycle](#2621-cycle)
      * [2.6.2.2 :enum](#2622-enum)
      * [2.6.2.3 :help](#2623-help)
      * [2.6.2.4 :marker](#2624-marker)
      * [2.6.2.5 :per_page](#2625-per_page)
      * [2.6.2.6 :disabled](#2626-disabled)
      * [2.6.2.7 :filter](#2627-filter)
    * [2.6.3 multi_select](#263-multi_select)
      * [2.6.3.1 :cycle](#2631-cycle)
      * [2.6.3.2 :enum](#2632-enum)
      * [2.6.3.3 :help](#2633-help)
      * [2.6.3.4 :per_page](#2634-per_page)
      * [2.6.3.5 :disabled](#2635-disabled)
      * [2.6.3.6 :echo](#2636-echo)
      * [2.6.3.7 :filter](#2637-filter)
      * [2.6.3.8 :min](#2638-min)
      * [2.6.3.9 :max](#2639-max)
    * [2.6.4 enum_select](#264-enum_select)
      * [2.6.4.1 :per_page](#2641-per_page)
      * [2.6.4.1 :disabled](#2641-disabled)
  * [2.7 expand](#27-expand)
    * [2.7.1 :auto_hint](#271-auto_hint)
  * [2.8 collect](#28-collect)
  * [2.9 suggest](#29-suggest)
  * [2.10 slider](#210-slider)
  * [2.11 say](#211-say)
    * [2.11.1 ok](#2111-ok)
    * [2.11.2 warn](#2112-warn)
    * [2.11.3 error](#2113-error)
  * [2.12 keyboard events](#212-keyboard-events)
  * [2.13 commands](#213-commands)
* [3. settings](#3-settings)
  * [3.1 :symbols](#31-symbols)
  * [3.2 :active_color](#32-active_color)
  * [3.3 :enable_color](#33-enable_color)
  * [3.4 :help_color](#34-help_color)
  * [3.5 :interrupt](#35-interrupt)
  * [3.6 :prefix](#36-prefix)
  * [3.7 :quiet](#37-quiet)
  * [3.8 :track_history](#38-track_history)

## 1. Usage

In order to start asking questions on the command line, create prompt:

```ruby
require "tty-prompt"

prompt = TTY::Prompt.new
```

And then call `ask` with the question for simple input:

```ruby
prompt.ask("What is your name?", default: ENV["USER"])
# => What is your name? (piotr)
```

To confirm input use `yes?`:

```ruby
prompt.yes?("Do you like Ruby?")
# => Do you like Ruby? (Y/n)
```

If you want to input password or secret information use `mask`:

```ruby
prompt.mask("What is your secret?")
# => What is your secret? ••••
```

Asking question with list of options couldn't be easier using `select` like so:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

Also, asking multiple choice questions is a breeze with `multi_select`:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices)
# =>
#
# Select drinks? (Use ↑/↓ arrow keys, press Space to select and Enter to finish)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

To ask for a selection from enumerated list you can use `enum_select`:

```ruby
choices = %w(emacs nano vim)
prompt.enum_select("Select an editor?", choices)
# =>
#
# Select an editor?
#   1) emacs
#   2) nano
#   3) vim
#   Choose 1-3 [1]:
```

However, if you have a lot of options to choose from you may want to use `expand`:

```ruby
choices = [
  { key: "y", name: "overwrite this file", value: :yes },
  { key: "n", name: "do not overwrite this file", value: :no },
  { key: "a", name: "overwrite this file and all later files", value: :all },
  { key: "d", name: "show diff", value: :diff },
  { key: "q", name: "quit; do not overwrite this file ", value: :quit }
]
prompt.expand("Overwrite Gemfile?", choices)
# =>
# Overwrite Gemfile? (enter "h" for help) [y,n,a,d,q,h]
```

If you wish to collect more than one answer use `collect`:

```ruby
result = prompt.collect do
  key(:name).ask("Name?")

  key(:age).ask("Age?", convert: :int)

  key(:address) do
    key(:street).ask("Street?", required: true)
    key(:city).ask("City?")
    key(:zip).ask("Zip?", validate: /\A\d{3}\Z/)
  end
end
# =>
# {:name => "Piotr", :age => 30, :address => {:street => "Street", :city => "City", :zip => "123"}}
```

## 2. Interface

### 2.1 ask

In order to ask a basic question do:

```ruby
prompt.ask("What is your name?")
```

However, to prompt for more complex input you can use robust API by passing hash of properties or using a block like so:

```ruby
prompt.ask("What is your name?") do |q|
  q.required true
  q.validate /\A\w+\Z/
  q.modify   :capitalize
end
```

#### 2.1.1 `:convert`

The `convert` property is used to convert input to a required type.

By default no conversion of input is performed. To change this use one of the following conversions:

* `:boolean`|`:bool` - e.g. 'yes/1/y/t/' becomes `true`, 'no/0/n/f' becomes `false`
* `:date` - parses dates formats "28/03/2020", "March 28th 2020"
* `:time` - parses time formats "11:20:03"
* `:float` - e.g. `-1` becomes `-1.0`
* `:int`|`:integer` - e.g. `+1` becomes `1`
* `:sym`|`:symbol` - e.g. "foo" becomes `:foo`
* `:filepath` - converts to file path
* `:path`|`:pathname` - converts to `Pathname` object
* `:range` - e.g. '1-10' becomes `1..10` range object
* `:regexp` - e.g. "foo|bar" becomes `/foo|bar/`
* `:uri` - converts to `URI` object
* `:list`|`:array` - e.g. 'a,b,c' becomes `["a", "b", "c"]`
* `:map`|`:hash` - e.g. 'a:1 b:2 c:3' becomes `{a: "1", b: "2", c: "3"}`

In addition you can specify a plural or append `list` or `array` to any base type:

* `:ints` or `:int_list` - will convert to a list of integers
* `:floats` or `:float_list` - will convert to a list of floats
* `:bools` or `:bool_list` - will convert to a list of booleans, e.g. `t,f,t` becomes `[true, false, true]`

Similarly, you can append `map` or `hash` to any base type:

* `:int_map`|`:integer_map`|`:int_hash` - will convert to a hash of integers, e.g `a:1 b:2 c:3` becomes `{a: 1, b: 2, c: 3}`
* `:bool_map` | `:boolean_map`|`:bool_hash` - will convert to a hash of booleans, e.g `a:t b:f c:t` becomes `{a: true, b: false, c: true}`

By default, `map` converts keys to symbols, if you wish to use strings instead specify key type like so:

* `:str_int_map` - will convert to a hash of string keys and integer values
* `:string_integer_hash` - will convert to a hash of string keys and integer values

For example, if you are interested in range type as answer do the following:

```ruby
prompt.ask("Provide range of numbers?", convert: :range)
# Provide range of numbers? 1-10
# => 1..10
```

If, on the other hand, you wish to convert input to a hash of integer values do:

```ruby
prompt.ask("Provide keys and values:", convert: :int_map)
# Provide keys and values: a=1 b=2 c=3
# => {a: 1, b: 2, c: 3}
```

If a user provides a wrong type for conversion an error message will be printed in the console:

```ruby
prompt.ask("Provide digit:", convert: :float)
# Provide digit: x
# >> Cannot convert `x` into 'float' type
```

You can further customize error message:

```ruby
prompt.ask("Provide digit:", convert: :float) do |q|
  q.convert(:float, "Wrong value of %{value} for %{type} conversion")
  # or
  q.convert :float
  q.messages[:convert?] = "Wrong value of %{value} for %{type} conversion"
end
```

You can also provide a custom conversion like so:

```ruby
prompt.ask("Ingredients? (comma sep list)") do |q|
  q.convert -> (input) { input.split(/,\s*/) }
end
# Ingredients? (comma sep list) milk, eggs, flour
# => ["milk", "eggs", "flour"]
```

#### 2.1.2 `:default`

The `:default` option is used if the user presses return key:

```ruby
prompt.ask("What is your name?", default: "Anonymous")
# =>
# What is your name? (Anonymous)
```

#### 2.1.3 `:value`

To pre-populate the input line for editing use `:value` option:

```ruby
prompt.ask("What is your name?", value: "Piotr")
# =>
# What is your name? Piotr
```

#### 2.1.4 `:echo`

To control whether the input is shown back in terminal or not use `:echo` option like so:

```ruby
prompt.ask("password:", echo: false)
```

#### 2.1.5 error messages

By default `tty-prompt` comes with predefined error messages for `convert`, `required`, `in`, `validate` options.

You can change these and configure to your liking either by passing message as second argument with the option:

```ruby
prompt.ask("What is your email?") do |q|
  q.validate(/\A\w+@\w+\.\w+\Z/, "Invalid email address")
end
```

Or change the `messages` key entry out of `:convert?`, `:range?`, `:required?` and `:valid?`:

```ruby
prompt.ask("What is your email?") do |q|
  q.validate(/\A\w+@\w+\.\w+\Z/)
  q.messages[:valid?] = "Invalid email address"
end
```

To change default range validation error message do:

```ruby
prompt.ask("How spicy on scale (1-5)? ") do |q|
  q.in "1-5"
  q.messages[:range?] = "%{value} out of expected range %{in}"
end
```

#### 2.1.6 `:in`

In order to check that provided input falls inside a range of inputs use the `in` option. For example, if we wanted to ask a user for a single digit in given range we may do following:

```ruby
prompt.ask("Provide number in range: 0-9?") { |q| q.in("0-9") }
```

#### 2.1.7 `:modify`

Set the `:modify` option if you want to handle whitespace or letter capitalization.

```ruby
prompt.ask("Enter text:") do |q|
  q.modify :strip, :collapse
end
```

Available letter casing settings are:
```ruby
:up         # change to upper case
:down       # change to small case
:capitalize # capitalize each word
```

Available whitespace settings are:

```ruby
:trim     # remove whitespace from both ends of the input
:strip    # same as :trim
:chomp    # remove whitespace at the end of input
:collapse # reduce all whitespace to single character
:remove   # remove all whitespace
```

#### 2.1.8 `:required`

To ensure that input is provided use `:required` option:

```ruby
prompt.ask("What's your phone number?", required: true)
# What's your phone number?
# >> Value must be provided
```

#### 2.1.9 `:validate`

In order to validate that input matches a given pattern you can pass the `validate` option/method.

Validate accepts `Regex`, `Proc` or `Symbol`.

```ruby
prompt.ask("What is your username?") do |q|
  q.validate(/\A[^.]+\.[^.]+\Z/)
end
```

The above can also be expressed as a `Proc`:

```ruby
prompt.ask("What is your username?") do |q|
  q.validate ->(input) { input =~ /\A[^.]+\.[^.]+\Z/ }
end
```

There is a built-in validation for `:email` and you can use it directly like so:

```ruby
prompt.ask("What is your email?") { |q| q.validate :email }
```

The default validation message is `"Your answer is invalid (must match %{valid})"` and you can customise it by passing in a second argument:

```ruby
prompt.ask("What is your username?") do |q|
  q.validate(/\A[^.]+\.[^.]+\Z/, "Invalid username: %{value}, must match %{valid}")
end
```

The default message can also be set using `messages` and the `:valid?` key:

```ruby
prompt.ask("What is your username?") do |q|
  q.validate(/\A[^.]+\.[^.]+\Z/)
  q.messages[:valid?] = "Invalid username: %{value}, must match %{valid}")
end
```

### 2.2. keypress

In order to ask question that awaits a single character answer use `keypress` prompt like so:

```ruby
prompt.keypress("Press key ?")
# Press key?
# => a
```

By default any key is accepted but you can limit keys by using `:keys` option. Any key event names such as `:space` or `:ctrl_k` are valid:

```ruby
prompt.keypress("Press space or enter to continue", keys: [:space, :return])
```

#### 2.2.1 timeout

Timeout can be set using `:timeout` option to expire prompt and allow the script to continue automatically:

```ruby
prompt.keypress("Press any key to continue, resumes automatically in 3 seconds ...", timeout: 3)
```

In addition the `keypress` recognises `:countdown` token when inserted inside the question. It will automatically countdown the time in seconds:

```ruby
prompt.keypress("Press any key to continue, resumes automatically in :countdown ...", timeout: 3)
```

### 2.3 multiline

Asking for multiline input can be done with `multiline` method. The reading of input will terminate when `Ctrl+d` or `Ctrl+z` is pressed. Empty lines will not be included in the returned array.

```ruby
prompt.multiline("Description?")
# Description? (Press CTRL-D or CTRL-Z to finish)
# I know not all that may be coming,
# but be it what it will,
# I'll go to it laughing.
# =>
# ["I know not all that may be coming,\n", "but be it what it will,\n", "I'll go to it laughing.\n"]
```

The `multiline` uses similar options to those supported by `ask` prompt. For example, to provide default description:

```ruby
prompt.multiline("Description?", default: "A super sweet prompt.")
```

Or using DSL:

```ruby
prompt.multiline("Description?") do |q|
  q.default "A super sweet prompt."
  q.help "Press thy ctrl+d to end"
end
```

### 2.4 mask

If you require input of confidential information use `mask` method. By default each character that is printed is replaced by `•` symbol. All configuration options applicable to `ask` method can be used with `mask` as well.

```ruby
prompt.mask("What is your secret?")
# => What is your secret? ••••
```

The masking character can be changed by passing the `:mask` key:

```ruby
heart = prompt.decorate(prompt.symbols[:heart] + " ", :magenta)
prompt.mask("What is your secret?", mask: heart)
# => What is your secret? ❤  ❤  ❤  ❤  ❤
```

If you don't wish to show any output use `:echo` option like so:

```ruby
prompt.mask("What is your secret?", echo: false)
```

You can also provide validation for your mask to enforce for instance strong passwords:

```ruby
prompt.mask("What is your secret?", mask: heart) do |q|
  q.validate(/[a-z\ ]{5,15}/)
end
```

### 2.5 yes?/no?

In order to display a query asking for boolean input from user use `yes?` like so:

```ruby
prompt.yes?("Do you like Ruby?")
# =>
# Do you like Ruby? (Y/n)
```

You can further customize question by passing `suffix`, `positive`, `negative` and `convert` options. The `suffix` changes text of available options, the `positive` specifies display string for successful answer and `negative` changes display string for negative answer. The final value is a boolean provided the `convert` option evaluates to boolean.

It's enough to provide the `suffix` option for the prompt to accept matching answers with correct labels:

```ruby
prompt.yes?("Are you a human?") do |q|
  q.suffix "Yup/nope"
end
# =>
# Are you a human? (Yup/nope)
```

Alternatively, instead of `suffix` option provide the `positive` and `negative` labels:

```ruby
prompt.yes?("Are you a human?") do |q|
  q.default false
  q.positive "Yup"
  q.negative "Nope"
end
# =>
# Are you a human? (yup/Nope)
```

Finally, providing all available options you can ask fully customized question:

```ruby
prompt.yes?("Are you a human?") do |q|
  q.suffix "Agree/Disagree"
  q.positive "Agree"
  q.negative "Disagree"
  q.convert -> (input) { !input.match(/^agree$/i).nil? }
end
# =>
# Are you a human? (Agree/Disagree)
```

There is also the opposite for asking confirmation of negative question:

```ruby
prompt.no?("Do you hate Ruby?")
# =>
# Do you hate Ruby? (y/N)
```

Similarly to `yes?` method, you can supply the same options to customize the question.

### 2.6 menu

### 2.6.1 choices

There are many ways in which you can add menu choices. The simplest way is to create an array of values:

```ruby
choices = %w(small medium large)
```

By default the choice name is also the value the prompt will return when selected. To provide custom values, you can provide a hash with keys as choice names and their respective values:

```ruby
choices = {small: 1, medium: 2, large: 3}
prompt.select("What size?", choices)
# =>
# What size? (Press ↑/↓ arrow to move and Enter to select)
# ‣ small
#   medium
#   large
```

Finally, you can define an array of choices where each choice is a hash value with `:name` & `:value` keys which can include other options for customising individual choices:

```ruby
choices = [
  {name: "small", value: 1},
  {name: "medium", value: 2, disabled: "(out of stock)"},
  {name: "large", value: 3}
]
```

You can specify `:key` as an additional option which will be used as short name for selecting the choice via keyboard key press.

Another way to create menu with choices is using the DSL and the `choice` method. For example, the previous array of choices with hash values can be translated as:

```ruby
prompt.select("What size?") do |menu|
  menu.choice name: "small",  value: 1
  menu.choice name: "medium", value: 2, disabled: "(out of stock)"
  menu.choice name: "large",  value: 3
end
# =>
# What size? (Press ↑/↓ arrow to move and Enter to select)
# ‣ small
# ✘ medium (out of stock)
#   large
```

or in a more compact way:

```ruby
prompt.select("What size?") do |menu|
  menu.choice "small", 1
  menu.choice "medium", 2, disabled: "(out of stock)"
  menu.choice "large", 3
end
```

#### 2.6.1.1 `:disabled`

The `:disabled` key indicates to display a choice as currently unavailable to select. Disabled choices are displayed with a cross `✘` character next to them. If the choice is disabled, it cannot be selected. The value for the `:disabled` is used next to the choice to provide reason for excluding it from the selection menu. For example:

```ruby
choices = [
  {name: "small", value: 1},
  {name: "medium", value: 2, disabled: "(out of stock)"},
  {name: "large", value: 3}
]
```

### 2.6.2 select

For asking questions involving list of options use `select` method by passing the question and possible choices:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

You can also provide options through DSL using the `choice` method for single entry and/or `choices` for more than one choice:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice "Scorpion"
  menu.choice "Kano"
  menu.choice "Jax"
end
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

By default the choice name is used as return value, but you can provide your custom values including a `Proc` object:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice "Scorpion", 1
  menu.choice "Kano", 2
  menu.choice "Jax", -> { "Nice choice captain!" }
end
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

If you wish you can also provide a simple hash to denote choice name and its value like so:

```ruby
choices = {"Scorpion" => 1, "Kano" => 2, "Jax" => 3}
prompt.select("Choose your destiny?", choices)
```

To mark particular answer as selected use `default` with either an index of the choice starting from `1` or a choice's name:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.default 3
  # or menu.default "Jax"

  menu.choice "Scorpion", 1
  menu.choice "Kano", 2
  menu.choice "Jax", 3
end
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
#   Scorpion
#   Kano
# ‣ Jax
```

#### 2.6.2.1 `:cycle`

You can navigate the choices using the arrow keys or define your own key mappings (see [keyboard events](#212-keyboard-events). When reaching the top/bottom of the list, the selection does not cycle around by default. If you wish to enable cycling, you can pass `cycle: true` to `select` and `multi_select`:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax), cycle: true)
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

#### 2.6.2.2 `:enum`

For ordered choices set `enum` to any delimiter String. In that way, you can use arrows keys and numbers (0-9) to select the item.

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.enum "."

  menu.choice "Scorpion", 1
  menu.choice "Kano", 2
  menu.choice "Jax", 3
end
# =>
# Choose your destiny? (Use ↑/↓ arrow or number (0-9) keys, press Enter to select)
#   1. Scorpion
#   2. Kano
# ‣ 3. Jax
```

#### 2.6.2.3 `:help`

You can configure help message with `:help` and when to display it with `:show_help` options. The help can be displayed on `start`, `never` or `always`:

```ruby
choices = %w(Scorpion Kano Jax)
prompt.select("Choose your destiny?", choices, help: "(Bash keyboard keys)", show_help: :always)
# =>
# Choose your destiny? (Bash keyboard keys)
# > Scorpion
#   Kano
#   Jax
```

#### 2.6.2.4 `:marker`

You can configure active marker like so:

```ruby
choices = %w(Scorpion Kano Jax)
prompt.select("Choose your destiny?", choices, symbols: { marker: ">" })
# =>
# Choose your destiny? (Use ↑/↓ and ←/→ arrow keys, press Enter to select)
# > Scorpion
#   Kano
#   Jax
```

#### 2.6.2.5 `:per_page`

By default the menu is paginated if selection grows beyond `6` items. To change this setting use `:per_page` configuration.

```ruby
letters = ("A".."Z").to_a
prompt.select("Choose your letter?", letters, per_page: 4)
# =>
# Which letter? (Use ↑/↓ and ←/→ arrow keys, press Enter to select)
# ‣ A
#   B
#   C
#   D
```

You can also customise page navigation text using `:help` option:
```ruby
letters = ("A".."Z").to_a
prompt.select("Choose your letter?") do |menu|
  menu.per_page 4
  menu.help "(Wiggle thy finger up/down and left/right to see more)"
  menu.choices letters
end
# =>
# Which letter? (Wiggle thy finger up/down and left/right to see more)
# ‣ A
#   B
#   C
#   D
```

#### 2.6.2.6 `:disabled`

To disable menu choice, use the `:disabled` key with a value that explains the reason for the choice being unavailable. For example, out of all warriors, the Goro is currently injured:

```ruby
warriors = [
  "Scorpion",
  "Kano",
  { name: "Goro", disabled: "(injury)" },
  "Jax",
  "Kitana",
  "Raiden"
]
```

The disabled choice will be displayed with a cross `✘` character next to it and followed by an explanation:

```ruby
prompt.select("Choose your destiny?", warriors)
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
# ✘ Goro (injury)
#   Jax
#   Kitana
#   Raiden
```

#### 2.6.2.7 `:filter`

To activate dynamic list searching on letter/number key presses use `:filter` option:

```ruby
warriors = %w(Scorpion Kano Jax Kitana Raiden)
prompt.select("Choose your destiny?", warriors, filter: true)
# =>
# Choose your destiny? (Use ↑/↓ arrow keys, press Enter to select, and letter keys to filter)
# ‣ Scorpion
#   Kano
#   Jax
#   Kitana
#   Raiden
```

After the user presses "k":

```ruby
# =>
# Choose your destiny? (Filter: "k")
# ‣ Kano
#   Kitana
```

After the user presses "ka":

```ruby
# =>
# Choose your destiny? (Filter: "ka")
# ‣ Kano
```

Filter characters can be deleted partially or entirely via, respectively, Backspace and Canc.

If the user changes or deletes a filter, the choices previously selected remain selected.

### 2.6.3 multi_select

For asking questions involving multiple selection list use `multi_select` method by passing the question and possible choices:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices)
# =>
#
# Select drinks? (Use ↑/↓ arrow keys, press Space to select and Enter to finish)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

As a return value, the `multi_select` will always return an array by default populated with the names of the choices. If you wish to return custom values for the available choices do:

```ruby
choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
prompt.multi_select("Select drinks?", choices)

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

To mark choice(s) as selected use the `default` option with either index(s) of the choice(s) starting from `1` or choice name(s):

```ruby
prompt.multi_select("Select drinks?") do |menu|
  menu.default 2, 5
  # or menu.default :beer, :whisky

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

#### 2.6.3.1 `:cycle`

Also like, `select`, the method takes an option `cycle` (which defaults to `false`), which lets you configure whether the selection should cycle around when reaching the top/bottom of the list when navigating:

```ruby
prompt.multi_select("Select drinks?", %w(vodka beer wine), cycle: true)
```

#### 2.6.3.2 `:enum`

Like `select`, for ordered choices set `enum` to any delimiter String. In that way, you can use arrows keys and numbers (0-9) to select the item.

```ruby
prompt.multi_select("Select drinks?") do |menu|
  menu.enum ")"

  menu.choice :vodka,   {score: 10}
  menu.choice :beer,    {score: 20}
  menu.choice :wine,    {score: 30}
  menu.choice :whisky,  {score: 40}
  menu.choice :bourbon, {score: 50}
end
# =>
# Select drinks? beer, bourbon
#   ⬡ 1) vodka
#   ⬢ 2) beer
#   ⬡ 3) wine
#   ⬡ 4) whisky
# ‣ ⬢ 5) bourbon
```

And when you press enter you will see the following selected:

```ruby
# Select drinks? beer, bourbon
# => [{score: 20}, {score: 50}]
```

#### 2.6.3.3 `:help`

You can configure help message with `:help` and when to display it with `:show_help` options. The help can be displayed on `start`, `never` or `always`:

```ruby
choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
prompt.multi_select("Select drinks?", choices, help: "Press beer can against keyboard", show_help: :always)
# =>
# Select drinks? (Press beer can against keyboard)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

#### 2.6.3.4 `:per_page`

By default the menu is paginated if selection grows beyond `6` items. To change this setting use `:per_page` configuration.

```ruby
letters = ("A".."Z").to_a
prompt.multi_select("Choose your letter?", letters, per_page: 4)
# =>
# Which letter? (Use ↑/↓ and ←/→ arrow keys, press Space to select and Enter to finish)
# ‣ ⬡ A
#   ⬡ B
#   ⬡ C
#   ⬡ D
```

#### 2.6.3.5 `:disabled`

To disable menu choice, use the `:disabled` key with a value that explains the reason for the choice being unavailable. For example, out of all drinks, the sake and beer are currently out of stock:

```ruby
drinks = [
  "bourbon",
  {name: "sake", disabled: "(out of stock)"},
  "vodka",
  {name: "beer", disabled: "(out of stock)"},
  "wine",
  "whisky"
]
```

The disabled choice will be displayed with a cross `✘` character next to it and followed by an explanation:

```ruby
prompt.multi_select("Choose your favourite drink?", drinks)
# =>
# Choose your favourite drink? (Use ↑/↓ arrow keys, press Space to select and Enter to finish)
# ‣ ⬡ bourbon
#   ✘ sake (out of stock)
#   ⬡ vodka
#   ✘ beer (out of stock)
#   ⬡ wine
#   ⬡ whisky
```

#### 2.6.3.6 `:echo`

To control whether the selected items are shown on the question
header use the :echo option:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices, echo: false)
# =>
# Select drinks?
#   ⬡ vodka
#   ⬢ 2) beer
#   ⬡ 3) wine
#   ⬡ 4) whisky
# ‣ ⬢ 5) bourbon
```

#### 2.6.3.7 `:filter`

To activate dynamic list filtering on letter/number typing, use the :filter option:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices, filter: true)
# =>
# Select drinks? (Use ↑/↓ arrow keys, press Space to select and Enter to finish, and letter keys to filter)
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

After the user presses "w":

```ruby
# Select drinks? (Filter: "w")
# ‣ ⬡ wine
#   ⬡ whisky
```

Filter characters can be deleted partially or entirely via, respectively, Backspace and Canc.

If the user changes or deletes a filter, the choices previously selected remain selected.

The `filter` option is not compatible with `enum`.

#### 2.6.3.8 `:min`

To force the minimum number of choices an user must select, use the `:min` option:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices, min: 3)
# =>
# Select drinks? (min. 3) vodka, beer
#   ⬢ vodka
#   ⬢ beer
#   ⬡ wine
#   ⬡ wiskey
# ‣ ⬡ bourbon
```

#### 2.6.3.9 `:max`

To limit the number of choices an user can select, use the `:max` option:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.multi_select("Select drinks?", choices, max: 3)
# =>
# Select drinks? (max. 3) vodka, beer, whisky
#   ⬢ vodka
#   ⬢ beer
#   ⬡ wine
#   ⬢ whisky
# ‣ ⬡ bourbon
```

### 2.6.4 enum_select

In order to ask for standard selection from indexed list you can use `enum_select` and pass question together with possible choices:

```ruby
choices = %w(emacs nano vim)
prompt.enum_select("Select an editor?", choices)
# =>
#
# Select an editor?
#   1) nano
#   2) vim
#   3) emacs
#   Choose 1-3 [1]:
```

Similar to `select` and `multi_select`, you can provide question options through DSL using `choice` method and/or `choices` like so:

```ruby
choices = %w(nano vim emacs)
prompt.enum_select("Select an editor?") do |menu|
  menu.choice :nano,  "/bin/nano"
  menu.choice :vim,   "/usr/bin/vim"
  menu.choice :emacs, "/usr/bin/emacs"
end
# =>
#
# Select an editor?
#   1) nano
#   2) vim
#   3) emacs
#   Choose 1-3 [1]:
#
# Select an editor? /bin/nano
```

You can change the indexed numbers formatting by passing `enum` option. The `default` option lets you specify which choice to mark as selected by default. It accepts an index of the choice starting from `1` or a choice name:

```ruby
choices = %w(nano vim emacs)
prompt.enum_select("Select an editor?") do |menu|
  menu.default 2
  # or menu.defualt "/usr/bin/vim"
  menu.enum "."

  menu.choice :nano,  "/bin/nano"
  menu.choice :vim,   "/usr/bin/vim"
  menu.choice :emacs, "/usr/bin/emacs"
end
# =>
#
# Select an editor?
#   1. nano
#   2. vim
#   3. emacs
#   Choose 1-3 [2]:
#
# Select an editor? /usr/bin/vim
```

#### 2.6.4.1 `:per_page`

By default the menu is paginated if selection grows beyond `6` items. To change this setting use `:per_page` configuration.

```ruby
letters = ("A".."Z").to_a
prompt.enum_select("Choose your letter?", letters, per_page: 4)
# =>
# Which letter?
#   1) A
#   2) B
#   3) C
#   4) D
#   Choose 1-26 [1]:
# (Press tab/right or left to reveal more choices)
```

#### 2.6.4.2 `:disabled`

To make a choice unavailable use the `:disabled` option and, if you wish, as value provide a reason:

```ruby
choices = [
  {name: "Emacs", disabled: "(not installed)"},
  "Atom",
  "GNU nano",
  {name: "Notepad++", disabled: "(not installed)"},
  "Sublime",
  "Vim"
]
```

The disabled choice will be displayed with a cross ✘ character next to it and followed by an explanation:


```ruby
prompt.enum_select("Select an editor", choices)
# =>
# Select an editor
# ✘ 1) Emacs (not installed)
#   2) Atom
#   3) GNU nano
# ✘ 4) Notepad++ (not installed)
#   5) Sublime
#   6) Vim
#   Choose 1-6 [2]:
```

### 2.7 expand

The `expand` provides a compact way to ask a question with many options.

As first argument `expand` takes the message to display and as a second an array of choices. Compared to the `select`, `multi_select` and `enum_select`, the choices need to be objects that include `:key`, `:name` and `:value` keys. The `:key` must be a single character. The help choice is added automatically as the last option under the key `h`.

```ruby
choices = [
  {
    key: "y",
    name: "overwrite this file",
    value: :yes
  }, {
    key: "n",
    name: "do not overwrite this file",
    value: :no
  }, {
    key: "q",
    name: "quit; do not overwrite this file ",
    value: :quit
  }
]
```

The choices can also be provided through DSL using the `choice` method. The `:value` can be a primitive value or `Proc` instance that gets executed and whose value is used as returned type. For example:

```ruby
prompt.expand("Overwrite Gemfile?") do |q|
  q.choice key: "y", name: "Overwrite"      do :ok end
  q.choice key: "n", name: "Skip",          value: :no
  q.choice key: "a", name: "Overwrite all", value: :all
  q.choice key: "d", name: "Show diff",     value: :diff
  q.choice key: "q", name: "Quit",          value: :quit
end
```

The first element in the array of choices or provided via `choice` DSL will be the default choice, you can change that by passing `default` option.

```ruby
prompt.expand("Overwrite Gemfile?", choices)
# =>
# Overwrite Gemfile? (enter "h" for help) [y,n,q,h]
```

Each time user types an option a hint will be displayed:

```ruby
# Overwrite Gemfile? (enter "h" for help) [y,n,a,d,q,h] y
# >> overwrite this file
```

If user types `h` and presses enter, an expanded view will be shown which further allows to refine the choice:

```ruby
# Overwrite Gemfile?
#   y - overwrite this file
#   n - do not overwrite this file
#   q - quit; do not overwrite this file
#   h - print help
#   Choice [y]:
```

Run `examples/expand.rb` to see the prompt in action.

#### 2.7.1 `:auto_hint`

To show hint by default use `:auto_hint` option:

```ruby
prompt.expand("Overwrite Gemfile?", choices, auto_hint: true)
# =>
# Overwrite Gemfile? (enter "h" for help) [y,n,q,h]
# >> overwrite this file
```

### 2.8 collect

In order to collect more than one answer use `collect` method. Using the `key` you can describe the answers key name. All the methods for asking user input such as `ask`, `mask`, `select` can be directly invoked on the key. The key composition is very flexible by allowing nested keys. If you want the value to be automatically converted to required type use [convert](#221-convert).

For example to gather some contact information do:

```ruby
prompt.collect do
  key(:name).ask("Name?")

  key(:age).ask("Age?", convert: :int)

  key(:address) do
    key(:street).ask("Street?", required: true)
    key(:city).ask("City?")
    key(:zip).ask("Zip?", validate: /\A\d{3}\Z/)
  end
end
# =>
# {:name => "Piotr", :age => 30, :address => {:street => "Street", :city => "City", :zip => "123"}}
```

In order to collect _mutliple values_ for a given key in a loop, chain `values` onto the `key` desired:

```ruby
result = prompt.collect do
  key(:name).ask("Name?")

  key(:age).ask("Age?", convert: :int)

  while prompt.yes?("continue?")
    key(:addresses).values do
      key(:street).ask("Street?", required: true)
      key(:city).ask("City?")
      key(:zip).ask("Zip?", validate: /\A\d{3}\Z/)
    end
  end
end
# =>
# {
#   :name => "Piotr",
#   :age => 30,
#   :addresses => [
#     {:street => "Street", :city => "City", :zip => "123"},
#     {:street => "Street", :city => "City", :zip => "234"}
#   ]
# }
```

### 2.9 suggest

To suggest possible matches for the user input use `suggest` method like so:

```ruby
prompt.suggest("sta", ["stage", "stash", "commit", "branch"])
# =>
# Did you mean one of these?
#         stage
#         stash
```

To customize query text presented pass `:single_text` and `:plural_text` options to respectively change the message when one match is found or many.

```ruby
possible = %w(status stage stash commit branch blame)
prompt.suggest("b", possible, indent: 4, single_text: "Perhaps you meant?")
# =>
# Perhaps you meant?
#     blame
```

### 2.10 slider

If you'd rather not display all possible values in a vertical list, you may consider using `slider`. The slider provides easy visual way of picking a value marked by `●` symbol.

For integers, you can set `:min`(defaults to 0), `:max` and `:step`(defaults to 1) options to configure slider range:

```ruby
prompt.slider("Volume", min: 0, max: 100, step: 5)
# =>
# Volume ──────────●────────── 50
# (Use ←/→ arrow keys, press Enter to select)
```

For everything else, you can provide an array of your desired choices:

```ruby
prompt.slider("Letter", ('a'..'z').to_a)
# =>
# Letter ────────────●───────────── m
# (Use ←/→ arrow keys, press Enter to select)
```

By default the slider is configured to pick middle of the range as a start value, you can change this by using the `:default` option:

```ruby
prompt.slider("Volume", max: 100, step: 5, default: 75)
# =>
# Volume ───────────────●────── 75
# (Use ←/→ arrow keys, press Enter to select)
```

You can also select the default value by name:

```ruby
prompt.slider("Letter", ('a'..'z').to_a, default: 'q')
# =>
# Letter ──────────────────●─────── q
# (Use ←/→ arrow keys, press Enter to select)
```

You can also change the default slider formatting using the `:format`. The value must contain the `:slider` token to show current value and any `sprintf` compatible flag for number display, in our case `%d`:

```ruby
prompt.slider("Volume", max: 100, step: 5, default: 75, format: "|:slider| %d%%")
# =>
# Volume |───────────────●──────| 75%
# (Use ←/→ arrow keys, press Enter to select)
```

You can also specify slider range with decimal numbers. For example, to have a step of `0.5` and display each value with a single decimal place use `%f` as format:

```ruby
prompt.slider("Volume", max: 10, step: 0.5, default: 5, format: "|:slider| %.1f")
# =>
# Volume |───────────────●──────| 7.5
# (Use ←/→ arrow keys, press Enter to select)
```

You can alternatively provide a proc/lambda to customize your formatting even further:

```ruby
slider_format = -> (slider, value) { "|#{slider}| #{value.zero? ? "muted" : "%.1f"}" % value }
prompt.slider("Volume", max: 10, step: 0.5, default: 0, format: slider_format)
# =>
# Volume |●─────────────────────| muted
# (Use ←/→ arrow keys, press Enter to select)
```

If you wish to change the slider handle and the slider range display use `:symbols` option:

```ruby
prompt.slider("Volume", max: 100, step: 5, default: 75, symbols: {bullet: "x", line: "_"})
# =>
# Volume _______________x______ 75%
# (Use ←/→ arrow keys, press Enter to select)
```

You can configure help message with `:help` and when to display with `:show_help` options. The help can be displayed on `start`, `never` or `always`:

```ruby
prompt.slider("Volume", max: 10, default: 7, help: "(Move arrows left and right to set value)", show_help: :always)
# =>
# Volume ───────────────●────── 7
# (Move arrows left and right to set value)
```

Slider can be configured through DSL as well:

```ruby
prompt.slider("What size?") do |range|
  range.max 100
  range.step 5
  range.default 75
  range.format "|:slider| %d%%"
end
# =>
# Volume |───────────────●──────| 75%
# (Use ←/→ arrow keys, press Enter to select)
```

```ruby
prompt.slider("What letter?") do |range|
  range.choices ('a'..'z').to_a
  range.format "|:slider| %s"
  range.default 'q'
end
# =>
# What letter? |──────────────────●───────| q
# (Use ←/→ arrow keys, press Enter to select)
```


### 2.11 say

To simply print message out to standard output use `say` like so:

```ruby
prompt.say(...)
```

The `say` method also accepts option `:color` which supports all the colors provided by [pastel](https://github.com/piotrmurach/pastel#3-supported-colors)

**TTY::Prompt** provides more specific versions of `say` method to better express intention behind the message such as `ok`, `warn` and `error`.

#### 2.11.1 ok

Print message(s) in green do:

```ruby
prompt.ok(...)
```

#### 2.11.2 warn

Print message(s) in yellow do:

```ruby
prompt.warn(...)
```

#### 2.11.3 error

Print message(s) in red do:

```ruby
prompt.error(...)
```

#### 2.12 keyboard events

All the prompt types, when a key is pressed, fire key press events. You can subscribe to listen to this events by calling `on` with type of event name.

```ruby
prompt.on(:keypress) { |event| ... }
```

The event object is yielded to a block whenever particular event fires. The event has `key` and `value` methods. Further, the `key` responds to following messages:

* `name`  - the name of the event such as :up, :down, letter or digit
* `meta`  - true if event is non-standard key associated
* `shift` - true if shift has been pressed with the key
* `ctrl`  - true if ctrl has been pressed with the key

For example, to add vim like key navigation to `select` prompt one would do the following:

```ruby
prompt.on(:keypress) do |event|
  if event.value == "j"
    prompt.trigger(:keydown)
  end

  if event.value == "k"
    prompt.trigger(:keyup)
  end
end
```

You can subscribe to more than one event:

```ruby
prompt.on(:keypress) { |key| ... }
      .on(:keydown)  { |key| ... }
```

The available events are:

* `:keypress`
* `:keydown`
* `:keyup`
* `:keyleft`
* `:keyright`
* `:keynum`
* `:keytab`
* `:keyenter`
* `:keyreturn`
* `:keyspace`
* `:keyescape`
* `:keydelete`
* `:keybackspace`

### 2.13 Commands

To show a command and the associated arguments in a list as the user enters keys into the input.

```ruby
prompt.command(">", { "read" => ["key"] })
# =>
# >
# read key
```

Commands are a pairing of a string for the command name and an array of arguments for the command.

If you only want a few commands to be displayed while typing you can use `num_commands_shown`.

```ruby
commands = {
  "read" => ["key"],
  "write" => ["key", "value"]
}
prompt.command(">", commands, num_commands_shown: 1)
# =>
# > wr
# write key value
```

## 3 settings

### 3.1. `:symbols`

Many prompts use symbols to display information. You can overwrite the default symbols for all the prompts using the `:symbols` key and hash of symbol names as value:

```ruby
prompt = TTY::Prompt.new(symbols: {marker: ">"})
```

The following symbols can be overwritten:

| Symbols     | Unicode | ASCII |
| ----------- |:-------:|:-----:|
|  tick       | `✓`     | `√`   |
|  cross      | `✘`     | `x`   |
|  marker     | `‣`     | `>`   |
|  dot        | `•`     | `.`   |
|  bullet     | `●`     | `O`   |
|  line       | `─`     | `-`   |
|  radio_on   | `⬢`     | `(*)` |
|  radio_off  | `⬡`     | `( )` |
|  arrow_up   | `↑`     | `↑`   |
|  arrow_down | `↓`     | `↓`   |
|  arrow_left | `←`     | `←`   |
|  arrow_right| `→`     | `→`   |

### 3.2 `:active_color`

All prompt types support `:active_color` option. By default it's set to `:green` value.

The `select`, `multi_select`, `enum_select` and `expand` prompts use the active color to highlight the currently selected choice.

The answer provided by the user is also highlighted with the active color.

This `:active_color` as value accepts either a color symbol or callable object.

For example, to change all prompts active color to `:cyan` do:

```ruby
prompt = TTY::Prompt.new(active_color: :cyan)
```

You could also use `pastel`:

```ruby
notice = Pastel.new.cyan.on_blue.detach
prompt = TTY::Prompt.new(active_color: notice)
````

Or use coloring of your own choice:

```
prompt = TTY::Prompt.new(active_color: ->(str) { my-color-gem(str) })
```

This option can be applied either globally for all prompts or individually:

```ruby
prompt.select("What size?", %w(Large Medium Small), active_color: :cyan)
```

Please [see pastel](https://github.com/piotrmurach/pastel#3-supported-colors) for all supported colors.

### 3.3 `:enable_color`

If you wish to disable coloring for a prompt simply pass `:enable_color` option

```ruby
prompt = TTY::Prompt.new(enable_color: false)
```

### 3.4 `:help_color`

The `:help_color` option is used to customize the display color for all the help text. By default it's set to `:bright_black` value.

Prompts such as `select`, `multi_select`, `expand` support `:help_color`. This option can be applied either globally for all prompts or individually.

The `:help_color` option as value accepts either a color symbol or callable object.

For example, to change all prompts help color to `:cyan` do:

```ruby
prompt = TTY::Prompt.new(help_color: :cyan)
```

You could also use `pastel`:

```ruby
notice = Pastel.new.cyan.on_blue.detach
prompt = TTY::Prompt.new(help_color: notice)
````

Or use coloring of your own choice:

```ruby
prompt = TTY::Prompt.new(help_color: ->(str) { my-color-gem(str) })
```

Or configure `:help_color` for an individual prompt:

```ruby
prompt.select("What size?", %w(Large Medium Small), help_color: :cyan)
```

Please [see pastel](https://github.com/piotrmurach/pastel#3-supported-colors) for all supported colors.

### 3.5 `:interrupt`

By default `InputInterrupt` error will be raised when the user hits the interrupt key(Control-C). However, you can customise this behaviour by passing the `:interrupt` option. The available options are:

* `:signal` - sends interrupt signal
* `:exit` - exits with status code
* `:noop` - skips handler
* custom proc

For example, to send interrupt signal do:

```ruby
prompt = TTY::Prompt.new(interrupt: :signal)
```

### 3.6 `:prefix`

You can prefix each question asked using the `:prefix` option. This option can be applied either globally for all prompts or individual for each one:

```ruby
prompt = TTY::Prompt.new(prefix: "[?] ")
```

### 3.7 `:quiet`

Prompts such as `select`, `multi_select`, `expand`, `slider` support `:quiet` which is used to disable re-echoing of the question and answer after selection is done. This option can be applied either globally for all prompts or individually.

```ruby
# global
prompt = TTY::Prompt.new(quiet: true)
# single prompt
prompt.select("What is your favorite color?", %w(blue yellow orange))
````

### 3.8 `:track_history`

The prompts that accept line input such as `multiline` or `ask` provide history buffer that tracks all the lines entered during `TTY::Prompt.new` interactions. The history buffer provides previous or next lines when user presses up/down arrows respectively. However, if you wish to disable this behaviour use `:track_history` option like so:

```ruby
prompt = TTY::Prompt.new(track_history: false)
```

## Contributing

1. Fork it ( https://github.com/piotrmurach/tty-prompt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Copyright

Copyright (c) 2015 Piotr Murach. See LICENSE for further details.
