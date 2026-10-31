# Lucee HSQLDB JDBC Extension

HSQLDB (HyperSQL DataBase) JDBC driver for Lucee. The extension ships the official `org.hsqldb:hsqldb` jar from Maven Central, which is an OSGi bundle (`org.hsqldb.hsqldb`).

- Lucee 7.1+ loads the driver through the `maven` coordinates in the extension manifest (`org.hsqldb:hsqldb`).
- Lucee 7.0 loads the OSGi bundle from the `jars` folder of the extension.
- The extension requires Lucee 7.0 or later. Lucee 6.x ships its own HSQLDB 2.7.2 driver and does not pick up the bundle of this extension.
- The Lucee core bundles HSQLDB 2.7.2 (`org.lucee.hsqldb`) which exports the same `org.hsqldb.*` packages as the official jar. To make sure the extension uses its own driver, the build removes the self-referencing `org.hsqldb.*` entries from `Import-Package` in the bundle manifest.

The version of the extension is the HSQLDB version plus a build number (for example `2.7.4.1`). The standard HSQLDB jar needs Java 11 or later.

## Build

```
mvn clean install
```

creates `target/hsqldb-jdbc-extension-<version>.lex` and `target/hsqldb-jdbc-extension-<version>.lite.lex` (without the `maven` folder).

## Issues

[HSQLDB Issues on Jira](https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22hsqldb%22)
