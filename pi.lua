RATIO      = math.pi / 4
FILE       = "pifile"
CSV        = false
THREADS    = 6 -- threads*
ITERATIONS = 10000

local function clear()
	io.write("\027[H\027[2J")
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

	io.write(string.format("%f (%d)", pi, #list))

	return pi
end

local function printThreads(threads)
	local piList = {}

	for a = 1, #threads do
		io.write(string.format("%d: ", a))

		piList[a] = printThread(threads[a])

		io.write("   ")

		if a % 3 == 0 then
			io.write("\n")
		end
	end

	local closestIndex = 1

	for a = 2, #piList do
		if math.abs(piList[a] - math.pi) < math.abs(piList[closestIndex] - math.pi) then
			closestIndex = a
		end
	end

	io.write(string.format("\n%d: %f (%f)\n", closestIndex, piList[closestIndex], math.abs(piList[closestIndex] - math.pi)))

	io.flush()

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
		io.write("\tfile=FILE                       file to write to, set blank to not write to file\n")
		io.write("\tcsv=CSV               (boolean) set to \"true\" to write in the CSV format\n")
		io.write("\tthreads=THREADS       (integer) threads* to create, only the closest thread is written to file\n")
		io.write("\titerations=ITERATIONS (integer) iterations to run until stopping\n")
		io.write("\npublic domain\n")

		os.exit(0)
	end

	local fileOption       = arg[a]:match("^file=(.+)$")
	local csvOption        = arg[a]:match("^csv=(.+)$")
	local threadsOption    = arg[a]:match("^threads=(.+)$")
	local iterationsOption = arg[a]:match("^iterations=(.+)$")

	if fileOption then
		FILE = fileOption
	elseif arg[a] == "file=" then
		FILE = nil
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
end

local threads = {}

for a = 1, THREADS do
	threads[a] = {}
end

local piFile = openFile()
local closestIndex
local closestPi

for iteration = 1, ITERATIONS do
	clear()

	for a = 1, THREADS do
		stepThread(threads[a])
	end

	closestIndex, closestPi = printThreads(threads)

	if iteration % 100 == 0 then
		writeIteration(piFile, iteration, closestPi, closestIndex)
	end

	iteration = iteration + 1
end
