local lu = require('luaunit')

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

function test_from_opthelp()
	local tests = {
		{argv={'-a'},					opts={a=1},						args={}},
		{argv={'-a','-a','-a'},		opts={a=3},						args={}},
		{argv={'-h', '--help'},		opts={h=2,help=2},			args={}},
		{argv={'-b','ma','-a'},		opts={b='ma',a=1},			args={}},
		{argv={'--outfile','m'},	opts={o='m', outfile='m'}, args={}},
		{argv={'--outfile=m'},		opts={o='m', outfile='m'}, args={}},
		{argv={'--infile','m'},		opts={infile='m'},			args={}},
		{argv={'--infile=m'},		opts={infile='m'},			args={}},
		{argv={'-h','OPT','-a'},	opts={h=1,help=1,a=1},		args={'OPT'}},
		{argv={'-a','-a','--','-a','foo'},	opts={a=2},			args={'-a','foo'}},
		{argv={'-s'},					opts={s=1,['without-optarg']=1},	args={}},
		{argv={'--single-longopt'}, opts={['single-longopt']=1}, args={}},
		{argv={'-ah'},					opts={a=1,h=1,help=1},		args={}},
		{argv={'-ab','B', '-a'},	opts={a=2,b='B'},				args={}},
		{argv={'-b','B','--infile=in'},opts={infile='in',b='B'},	args={}},
		{argv={'--infile=in','-a','-a','B'},opts={infile='in',a=2},	args={'B'}},
		{argv={'--infile=in','-b','B'},opts={infile='in',b='B'},	args={}},
		{argv={'--infile=in','--outfile=out'},opts={infile='in',o='out', outfile='out'},	args={}},
	}
	for _, t in pairs(tests) do
		local opts, args = optarg.from_opthelp(opthelp, t.argv)
		lu.assertEquals(opts, t.opts, "args failed: "..table.concat(t.argv,' '))
		lu.assertEquals(args, t.args)
	end
end

function test_missing_optarg()
	local called=false
	local opts, args = optarg.from_opthelp(opthelp, {'-b'}, function()
		called=true
	end)
	lu.assertNil(opts)
	lu.assertTrue(called)
end

os.exit(lu.LuaUnit.run())
