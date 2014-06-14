working_directory "/home/people-production/current"
worker_processes 4
preload_app false
timeout 180
listen "127.0.0.1:4005"
stderr_path "/home/people-production/current/log/production.log"
stdout_path "/home/people-production/current/log/production.log"
pid "/home/people-production/current/tmp/pids/unicorn.pid"