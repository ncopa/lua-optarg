lua-optarg
==========

Simple command line option parser for Lua which uses GNU style option help
text as specification. A lighter alternative to `pl.lapp`.

It supports prefixed long option (eg. '--long-option'), short option
(eg. '-h') s) and options with arguments.

Functions
---------

### function from_opthelp(helptext, argv, errfunc)

Parse `argv` option array according the specification in helptext. If argv
is omitted (or nil) it wil use `_G.arg`.

If invalid options are found, `errfunc` is called and return value is
returned. If `errfunc` is omitted (or nil), the will error message be
printed to stderr.

The function returns two table, one with the parsed options and one with the
reminding arguments.

Option parsing is stopped at first non-option argument or at first `--`.

Example
--------
```Lua
opthelp = [[
 -a                 Short option.
 -b, --both         Both long and short option.
 -c OPTARG          Short option with required argument OPTARG.
 -d, --with-arg=OPTARG
                    Another option with both short and long name with reqired
                    argument OPTARG.

Options without required option arguments may be specified multiple times.
]]

opts, args = require('optarg').from_opthelp(opthelp)

if not opts then
	print("Usage: ".._G.arg[0]..": [-ab] [-c OPTARG] [-d OPTARG] [ARG...]")
	print(opthelp)
	os.exit(1)
end

if opts.a then
	print(("Option '-a' specified %d times."):format(opts.a))
end

-- note that opts.b == opts.both
if opts.b then
	print(("Option '-b' or '--both'  specified %d times."):format(opts.both))
end

if opts.c then
	print(("Option '-c' was set to '%s'."):format(opts.c))
end

--note that opts.d == opts["with-arg"]
if opts.d then
	print(("Option '-d' or '--with-arg' was set to '%s'.")
		:format(opts['with-arg']))
end

for i = 1,#args do
	print(("args[%d]=%s"):format(i, args[i]))
end
```

License
-------
MIT

