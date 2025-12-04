workers Integer(ENV['WORKERS_NUM'] || 1)

max_threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 1)

min_threads_count = 0

threads min_threads_count, max_threads_count