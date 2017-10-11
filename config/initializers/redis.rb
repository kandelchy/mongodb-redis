# $redis = Redis::Namespace.new(:redis => Redis.new)
#redis = Redis.new(host: "10.0.1.1", port: 6379, db:0)
redis_options = {
  url: 'redis://example-test',
  sentinels: [ { host: "127.0.0.1", port: 26379 },
               { host: "127.0.0.1", port: 26379 },
               { host: "127.0.0.1", port: 26379 }],
  role: 'master'
}


$REDIS = Redis.new(redis_options)
$messageno=0
