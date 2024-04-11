RATIO      = math.pi / 4
FILE       = false
CSV        = false
THREADS    = 6 -- threads*
ITERATIONS = 10000
WINTERVAL  = 100
VERBOSE    = false

local function print(format, ...)
	if VERBOSE then
		io.write(string.format(format, ...))
		io.flush()
	end
end

local function stepThread(list)
	local value    = math.random()
	local inCircle = 0;

	list[#list + 1] = value <= RATIO
end

local function printThread(list)
	local inCircle = 0

	for a = 1, #list do
		if list[a] then
			inCircle = inCircle + 1
		end
	end

	local pi = inCircle * 4 / # list

	print("%f (%d)", pi, #list)

	return pi
end

local function printThreads(threads)
	local piList = {}

	for a = 1, #threads do
		print("%d: ", a)

		piList[a] = printThread(threads[a])

		print("    ")

		if a % 3 == 0 or a == #threads then
			print("\n")
		end
	end

	local closestIndex = 1

	for a = 2, #piList do
		if math.abs(piList[a] - math.pi) < math.abs(piList[closestIndex] - math.pi) then
			closestIndex = a
		end
	end

	print("\n%d: %f (%f)\n\n", closestIndex, piList[closestIndex], math.abs(piList[closestIndex] - math.pi))

	return closestIndex, piList[closestIndex]
end

local function openFile()
	if not FILE then
		return
	end

	local f, err = io.open(FILE, "w")

	if not f then
		io.write(err, "\n");
		io.flush()

		os.exit(1)
	end

	if CSV then
		f:write("Iteration, SD\n")
		f:flush()
	end

	return f
end

local function writeIteration(f, iteration, closestPi, closestIndex)
	if not FILE then
		return
	end

	if CSV then
		f:write(string.format("%d, %f\n", iteration, math.abs(closestPi - math.pi)))
	else
		f:write(string.format("%d: %f (%f) (%d)\n", iteration, closestPi, math.abs(closestPi - math.pi), closestIndex))
	end

	f:flush()
end

for a = 1, #arg do
	if arg[a] == "--help" or arg[a] == "-h" then
		io.write("this small lua program doesnt need a help menu but here\n")
		io.write("\t--help|-h                       display this menu\n")
		io.write("\t--verbose|-v                    display verbose output\n")
		io.write("\tfile=FILE                       file to write to, dont set to not write to file\n")
		io.write("\tcsv=CSV               (boolean) set to \"true\" to write in the CSV format\n")
		io.write("\tthreads=THREADS       (integer) threads* to create, only the closest thread is written to file\n")
		io.write("\titerations=ITERATIONS (integer) iterations to run until stopping\n")
		io.write("\twinterval=WINTERVAL   (integer) write to the output file every WINTERVAL iterations\n")
		io.write("\npublic domain\n")

		os.exit(0)
	elseif arg[a] == "--verbose" or arg[a] == "-v" then
		VERBOSE = true
	end

	local fileOption       = arg[a]:match("^file=(.+)$")
	local csvOption        = arg[a]:match("^csv=(.+)$")
	local threadsOption    = arg[a]:match("^threads=(.+)$")
	local iterationsOption = arg[a]:match("^iterations=(.+)$")
	local wintervalOption  = arg[a]:match("^winterval=(.+)$")

	if fileOption then
		FILE = fileOption
	end

	if csvOption == "true" then
		CSV = true
	end

	if threadsOption then
		threadsOption = tonumber(threadsOption)

		if not threadsOption then
			io.write("threads must be an integer\n")
			io.flush()

			os.exit(1)
		elseif threadsOption * 10 % 10 ~= 0 then
			io.write("threads must be an integer\n")
			io.flush()

			os.exit(1)
		end

		THREADS = threadsOption
	end

	if iterationsOption then
		iterationsOption = tonumber(iterationsOption)

		if not iterationsOption then
			io.write("iterations must be an integer\n")
			io.flush()

			os.exit(1)
		elseif iterationsOption * 10 % 10 ~= 0 then
			io.write("iterations must be an integer\n")
			io.flush()

			os.exit(1)
		end

		ITERATIONS = iterationsOption
	end

	if wintervalOption then
		wintervalOption = tonumber(wintervalOption)

		if not wintervalOption then
			io.write("winterval must be an integer\n")
			io.flush()

			os.exit(1)
		elseif wintervalOption * 10 % 10 ~= 0 then
			io.write("winterval must be an integer\n")
			io.flush()

			os.exit(1)
		end

		WINTERVAL = wintervalOption
	end
end

local threads = {}

for a = 1, THREADS do
	threads[a] = {}
end

local piFile = openFile()
local closestIndex
local closestPi

for iteration = 1, ITERATIONS do
	for a = 1, THREADS do
		stepThread(threads[a])
	end

	closestIndex, closestPi = printThreads(threads)

	if iteration % WINTERVAL == 0 then
		writeIteration(piFile, iteration, closestPi, closestIndex)
	end

	iteration = iteration + 1
end

io.write(string.format("%f\n", closestPi))
