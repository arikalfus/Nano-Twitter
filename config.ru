# Config.ru configures the interface between "Rack" and Sinatra

# --- Start of unicorn worker killer code ---

require 'unicorn/worker_killer'

max_request_min = 500
max_request_max = 600

# Max requests per worker
use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

oom_min = 240 * (1024**2)
oom_max = 260 * (1024**2)

# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, oom_min, oom_max

# --- End of unicorn worker killer code ---

# --- Start of Unicorn GC code ---

GC_FREQUENCY = 25
require 'unicorn/oob_gc'
GC.disable # don't run GC during requests
use Unicorn::OobGC, GC_FREQUENCY # only GC once every GC_FREQUENCY

# --- End of Unicorn GC code ---

require_relative 'app'
run Sinatra::Application