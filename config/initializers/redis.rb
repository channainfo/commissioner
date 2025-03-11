# # config/initializers/redis.rb (or in your gem's configuration)
# require 'redis'
# require 'connection_pool'

# # Puma thread settings (e.g., from config/puma.rb)
# puma_threads_min = ENV['PUMA_MIN_THREADS']&.to_i || 0
# puma_threads_max = ENV['PUMA_MAX_THREADS']&.to_i || 16

# # Sidekiq concurrency (e.g., from config/sidekiq.yml or default)
# sidekiq_concurrency = ENV['SIDEKIQ_CONCURRENCY']&.to_i || 10

# # Total pool size: Puma threads + Sidekiq workers + buffer
# REDIS_POOL_SIZE = puma_threads_max + sidekiq_concurrency + 5 # Buffer for safety

# REDIS_TIMEOUT = 5 # seconds

# # Define the Redis connection pool
# REDIS_POOL = ConnectionPool.new(size: REDIS_POOL_SIZE, timeout: REDIS_TIMEOUT) do
#   Redis.new(
#     url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
#     timeout: REDIS_TIMEOUT
#   )
# end
