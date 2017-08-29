var HBaseConfiguration = Java.type("org.apache.hadoop.hbase.HBaseConfiguration")
var config = HBaseConfiguration.create();

var Path = Java.type("org.apache.hadoop.fs.Path");
var hbaseSitePath = new Path("/usr/local/hbase-1.2/conf/hbase-site.xml");
config.addResource(hbaseSitePath);

var ConnectionFactory = Java.type("org.apache.hadoop.hbase.client.ConnectionFactory")
var conn = ConnectionFactory.createConnection(config)
var HDocumentDB = Java.type("io.hdocdb.store.HDocumentDB")
db = new HDocumentDB(conn)