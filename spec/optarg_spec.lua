local optarg = require("optarg")

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

describe("optarg Tests", function()
	local tests = {
		{
			desc = "should take - as arg",
			argv = { "-" },
			opts = {},
			args = { "-" },
		},
		{
			desc = "should accept a single short opt",
			argv = { "-a" },
			opts = { a = 1 },
			args = {},
		},
		{
			desc = "should count multiple short opts",
			argv = { "-a", "-a", "-a" },
			opts = { a = 3 },
			args = {},
		},
		{
			desc = "should stop pare args after --",
			argv = { "-a", "--", "-a", "-a" },
			opts = { a = 1 },
			args = { "-a", "-a" },
		},
		{
			desc = "should count both short and long opts",
			argv = { "-h", "--help" },
			opts = { h = 2, help = 2 },
			args = {},
		},
		{
			desc = "should take one short opt with argument, and one without",
			argv = { "-b", "ma", "-a" },
			opts = { b = "ma", a = 1 },
			args = {},
		},
		{
			desc = "should take a long opt without separate for arg",
			argv = { "--outfile", "m" },
			opts = { o = "m", outfile = "m" },
			args = {},
		},
		{
			desc = "should take a long opt with separate for arg",
			argv = { "--outfile=m" },
			opts = { o = "m", outfile = "m" },
			args = {},
		},
		{
			desc = "should take a long opt without separator. No short opt",
			argv = { "--infile", "m" },
			opts = { infile = "m" },
			args = {},
		},
		{
			desc = "should take a long opt with separator. No short opt",
			argv = { "--infile=m" },
			opts = { infile = "m" },
			args = {},
		},
		{
			desc = "should take an arg between two opts",
			argv = { "-h", "OPT", "-a" },
			opts = { h = 1, help = 1, a = 1 },
			args = { "OPT" },
		},
		{
			desc = "should stop parse opts after --",
			argv = { "-a", "-a", "--", "-a", "foo" },
			opts = { a = 2 },
			args = { "-a", "foo" },
		},
		{
			desc = "should set the longopt",
			argv = { "-s" },
			opts = { s = 1, ["without-optarg"] = 1 },
			args = {},
		},
		{
			desc = "should accept a single long opt",
			argv = { "--single-longopt" },
			opts = { ["single-longopt"] = 1 },
			args = {},
		},
		{
			desc = "should separate a string of short opt characters",
			argv = { "-ah" },
			opts = { a = 1, h = 1, help = 1 },
			args = {},
		},
		{
			desc = "should set optarg for short opt",
			argv = { "-ab", "B", "-a" },
			opts = { a = 2, b = "B" },
			args = {},
		},
		{
			desc = "should set optarg for both short and long opt with optarg",
			argv = { "-b", "B", "--infile=in" },
			opts = { infile = "in", b = "B" },
			args = {},
		},
		{
			desc = "should count short opts and set longopt optarg, and set arg",
			argv = { "--infile=in", "-a", "-a", "B" },
			opts = { infile = "in", a = 2 },
			args = { "B" },
		},
		{
			desc = "should set optarg for both long and short opt",
			argv = { "--infile=in", "-b", "B" },
			opts = { infile = "in", b = "B" },
			args = {},
		},
		{
			desc = "should set optarg for both long opts",
			argv = { "--infile=in", "--outfile=out" },
			opts = { infile = "in", o = "out", outfile = "out" },
			args = {},
		},
		{
			desc = "should overide the optarg with the last",
			argv = { "--infile=foo", "--infile", "bar" },
			opts = { infile = "bar" }, -- last option wins
			args = {},
		},
	}
	for _, test in pairs(tests) do
		local opts, args = optarg.from_opthelp(opthelp, test.argv)
		it(test.desc, function()
			local t = test
			assert.same(opts, t.opts, "args failed: " .. table.concat(t.argv, " "))
			assert.same(args, t.args)
		end)
	end

	it("test_missing_optarg", function()
		local called = false
		local opts, _ = optarg.from_opthelp(opthelp, { "-b" }, function()
			called = true
		end)
		assert.is_nil(opts)
		assert.is_true(called)
	end)

	it("test_multi_optargs", function()
		-- last option wins
		local opts, _ = optarg.from_opthelp(opthelp, { "-b", "foo", "-b", "bar" })
		assert.same(opts, { b = "bar" })

		-- when multiargs is ste we store the args to the options in an array
		optarg.multiargs = true
		opts, _ = optarg.from_opthelp(opthelp, { "--infile=FILE" })
		assert.same(opts, { infile = { "FILE" } })
		opts, _ = optarg.from_opthelp(opthelp, { "-b", "foo", "-b", "bar" })
		assert.same(opts, { b = { "foo", "bar" } })
		optarg.multiargs = nil
	end)

	it("test_long_opt_after_arg", function()
		optarg = require("optarg")
		local usage = [[
            Usage: program [options] [args]
           -l, --long-opt=value
        ]]
		local opts, args = optarg.from_opthelp(usage, { "arg1", "--long-opt=value" })
		assert.are.same(opts, { ["l"] = "value", ["long-opt"] = "value" })
		assert.are.same(args, { "arg1" })
	end)

	it("test_long_opt_before_arg", function()
		local usage = [[
            Usage: program [options] [args]
           -l, --long-opt=value
        ]]
		local opts, args = optarg.from_opthelp(usage, { "--long-opt=value", "arg1" })
		assert.same(opts, { ["l"] = "value", ["long-opt"] = "value" })
		assert.same(args, { "arg1" })
	end)

	it("test_long_opt_without_separator", function()
		local usage = [[
            Usage: program [options] [args]
           -l, --long-opt=value
        ]]
		local opts, args = optarg.from_opthelp(usage, { "--long-opt", "value", "arg1" })
		assert.same(opts, { ["l"] = "value", ["long-opt"] = "value" })
		assert.same(args, { "arg1" })
	end)
end)
