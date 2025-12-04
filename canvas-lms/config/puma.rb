workers Integer(ENV['WORKERS_NUM'] || 2)
max_threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
min_threads_count = Integer(ENV['RAILS_MIN_THREADS'] || max_threads_count)
threads min_threads_count, max_threads_count

worker_timeout Integer(ENV['PUMA_WORKER_TIMEOUT'] || 60)
