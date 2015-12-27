# Change log

## [v0.3.0] - 2015-12-**

### Added
* Add prefix option to prompt to customize #ask, #select, #multi_select
* Add default printing to #ask
* Add #yes?/#no? boolean queries
* Add Evaluator and Result for validation checking to Question
* Add ability for #ask to display error messages on failed validation
* Add ability to specify in-built names for validation e.i. :email
* Add KeyEvent for keyboard events publishing to Reader
* Add #read_multiline to Reader
* Add :convert option for ask configuration
* Add ability to specify custom proc converters
* Add #ask_keypress to gather character input
* Add #ask_multiline to gather multiline input
* Add MaskedQuestion & #mask method for masking input stream characters

### Changed
* Change Reader#read_keypress to be robust and read correctly byte sequences
* Change Reader#getc to #read_line and extend arguments with echo option
* Extract cursor movement to dependency tty-cursor
* Change List & MultiList to subscribe to keyboard events
* Change to move mode inside reader namespace
* Remove Response & Error objects
* Remove :char option from #ask
* Change :read option to specify mode of reading out of :line, :multiline, :keypress

## [v0.2.0] - 2015-11-23

### Added
* Add ability to select choice form list #select
* Add ability to select multiple options #multi_select
* Add :read option to #ask for reading specific type input

### Changed
* Change #ask api to be similar to #select and #multi_select behaviour
* Change #ask :argument option to be :required
* Remove :valid option from #ask as #select is a better solution

## [v0.1.0] - 2015-11-01

* Initial implementation and release

[v0.3.0]: https://github.com/peter-murach/tty-prompt/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/peter-murach/tty-prompt/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/tty-prompt/compare/v0.1.0
