local lu = require('luaunit')



local opthelp = [[
Options:
 -a                    A short option without long option
 -b DIRECTORY          A short option with required option DIRECTORY
 -h, --help            A simple option with long name
 -q, --quiet           Another simple option with long name
 -o, --outfile=FILE    An option with required optarg FILE
 -s, --without-optarg  This is similar -b but wihtout the
     --single-longopt  This is a longopt without shortopt
                       but with multiline helptext
     --infile=FILE     This is a longopt with required optarg, without shortopt

Note that leading space is required for options.
Option parsing is stopped at '--'.

]]

-- luacheck: globals test_from_opthelp
function test_from_opthelp()
	local optarg = require("optarg")
	local tests = {
		{
			argv = { '-a' },
			opts = { a = 1 },
			args = {}
		},
		{
			argv = { '-a', '-a', '-a' },
			opts = { a = 3 },
			args = {}
		},
		{
			argv = { '-h', '--help' },
			opts = { h = 2, help = 2 },
			args = {}
		},
		{
			argv = { '-b', 'ma', '-a' },
			opts = { b = 'ma', a = 1 },
			args = {}
		},
		{
			argv = { '--outfile', 'm' },
			opts = { o = 'm', outfile = 'm' },
			args = {}
		},
		{
			argv = { '--outfile=m' },
			opts = { o = 'm', outfile = 'm' },
			args = {}
		},
		{
			argv = { '--infile', 'm' },
			opts = { infile = 'm' },
			args = {}
		},
		{
			argv = { '--infile=m' },
			opts = { infile = 'm' },
			args = {}
		},
		{
			argv = { '-h', 'OPT', '-a' },
			opts = { h = 1, help = 1, a = 1 },
			args = { 'OPT' }
		},
		{
			argv = { '-a', '-a', '--', '-a', 'foo' },
			opts = { a = 2 },
			args = { '-a', 'foo' }
		},
		{
			argv = { '-s' },
			opts = { s = 1, ['without-optarg'] = 1 },
			args = {}
		},
		{
			argv = { '--single-longopt' },
			opts = { ['single-longopt'] = 1 },
			args = {}
		},
		{
			argv = { '-ah' },
			opts = { a = 1, h = 1, help = 1 },
			args = {}
		},
		{
			argv = { '-ab', 'B', '-a' },
			opts = { a = 2, b = 'B' },
			args = {}
		},
		{
			argv = { '-b', 'B', '--infile=in' },
			opts = { infile = 'in', b = 'B' },
			args = {}
		},
		{
			argv = { '--infile=in', '-a', '-a', 'B' },
			opts = { infile = 'in', a = 2 },
			args = { 'B' }
		},
		{
			argv = { '--infile=in', '-b', 'B' },
			opts = { infile = 'in', b = 'B' },
			args = {}
		},
		{
			argv = { '--infile=in', '--outfile=out' },
			opts = { infile = 'in', o = 'out', outfile = 'out' },
			args = {}
		},
		{
			argv = { '--infile=foo', '--infile', 'bar' },
			opts = { infile = 'bar' }, -- last option wins
			args = {}
		},
	}
	for _, t in pairs(tests) do
		local opts, args = optarg.from_opthelp(opthelp, t.argv)
		lu.assertEquals(opts, t.opts, "args failed: " .. table.concat(t.argv, ' '))
		lu.assertEquals(args, t.args)
	end
end

-- luacheck: globals test_missing_optarg
function test_missing_optarg()
	local optarg = require("optarg")
	local called = false
	local opts, _ = optarg.from_opthelp(opthelp, { '-b' }, function()
		called = true
	end)
	lu.assertNil(opts)
	lu.assertTrue(called)
end

--luacheck: globals test_multi_optargs
function test_multi_optargs()
	local optarg = require("optarg")
	-- last option wins
	local opts, _ = optarg.from_opthelp(opthelp, { '-b', 'foo', '-b', 'bar' })
	lu.assertEquals(opts, { b = 'bar' })

	-- when multiargs is ste we store the args to the options in an array
	optarg.multiargs = true
	opts, _ = optarg.from_opthelp(opthelp, { '--infile=FILE' })
	lu.assertEquals(opts, { infile = { 'FILE' } })
	opts, _ = optarg.from_opthelp(opthelp, { '-b', 'foo', '-b', 'bar' })
	lu.assertEquals(opts, { b = { 'foo', 'bar' } })
end

-- luacheck: globals test_long_opt_after_arg
function test_long_opt_after_arg()
	local optarg = require("optarg")
	local usage = [[
		Usage: program [options] [args]
	   -l, --long-opt=value
	]]
	local opts, args = optarg.from_opthelp(usage, { "arg1", "--long-opt=value" })
	lu.assertEquals(opts, { ["l"] = "value", ["long-opt"] = "value" })
	lu.assertEquals(args, { "arg1" })
end

-- luacheck: globals test_long_opt_before_arg
function test_long_opt_before_arg()
	local optarg = require("optarg")
	local usage = [[
		Usage: program [options] [args]
	   -l, --long-opt=value
	]]
	local opts, args = optarg.from_opthelp(usage, { "--long-opt=value", "arg1" })
	lu.assertEquals(opts, { ["l"] = "value", ["long-opt"] = "value" })
	lu.assertEquals(args, { "arg1" })
end

-- luacheck: globals test_long_opt_without_separator
function test_long_opt_without_separator()
	local optarg = require("optarg")
	local usage = [[
		Usage: program [options] [args]
	   -l, --long-opt=value
	]]
	local opts, args = optarg.from_opthelp(usage, { "--long-opt", "value", "arg1" })
	lu.assertEquals(opts, { ["l"] = "value", ["long-opt"] = "value" })
	lu.assertEquals(args, { "arg1" })
end

os.exit(lu.LuaUnit.run())
