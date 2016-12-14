#Cassandra repair

This is a shell script to schedule repairs on Cassandra nodes.

##Usage

```bash
$ sh repair.sh <keyspace> <node-host> <nodetool-path> <statsd-host> <statsd-port> <datacenter>
```

- keyspace: Cassandra keyspace.
- node-host: The ip of the Cassandra node you want to run the repair.
- nodetool-path: The fullpath of nodetool according with your installation setup.
- statsd-host: Host of statsd for metrics.
- statsd-port: Port of statsd for metrics.
- datacenter: If you run in a multi-datacenter environment, specify this option according to the datacenter that your node belongs.

##License

This is a open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
