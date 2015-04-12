
optarg = require("optarg")


opthelp = [[
Options:
 -a                    A short option without long option
 -b DIRECTORY          A short option with required option DIRECTORY
 -h, --help            A simple option with long name
 -q, --quiet           Another simple option with long name
 -o, --outfile=FILE    An option with required optarg FILE
 -s, --without-optarg  This is similar -b but wihtout the 
     --single-longopt  This is a longopt without shortopt

Note that leading space is required for options.
Option parsing is stopped at '--'.

]]

opts, args = optarg.from_opthelp(opthelp)

if not opts or opts.help then
	print(("Usage: %s [-ahqs] [-b DIRECTORY] [-o FILE] [--] [FILE...]"):format(_G.arg[0]))
	print(opthelp)
	os.exit(opts and 1 or 0)
end

for k,v in pairs(opts) do
	print ("option:", k,"value:",v)
end

for i =1, #args do
	print(("args[%i]:\t%s"):format(i,args[i]))
end

