component extends="org.lucee.cfml.test.LuceeTestCase" labels="hsqldb" {

	// keep in sync with pom.xml driverVersion
	variables.driverVersion = "2.7.4";
	variables.bundleName = "org.hsqldb.hsqldb";

	private boolean function luceeSupportsMavenJdbc() {
		try {
			return server.doesJDBCSupportMaven();
		} catch ( any e ) {
			return false;
		}
	}

	private struct function getDatasourceDefinition() {
		var ds = {
			class: "org.hsqldb.jdbcDriver",
			connectionString: "jdbc:hsqldb:mem:ldev5262"
		};

		// Lucee 7.1+ prefers the maven coordinates, older versions load the OSGi bundle shipped in the extension
		if ( luceeSupportsMavenJdbc() ) {
			ds.maven = "org.hsqldb:hsqldb:#variables.driverVersion#";
		} else {
			ds.bundleName = variables.bundleName;
			ds.bundleVersion = variables.driverVersion;
		}
		return ds;
	}

	function run( testResults, testBox ) {
		describe( title="HSQLDB JDBC extension", body=function() {

			it( title="provides HSQLDB #variables.driverVersion#", body=function( currentSpec ) {
				var ds = getDatasourceDefinition();

				dbinfo datasource=ds name="local.dbVersion" type="version";

				systemOutput( "HSQLDB JDBC driver info: " & serializeJSON( {
					luceeVersion: server.lucee.version,
					datasource: ds,
					driverName: dbVersion.driver_name,
					driverVersion: dbVersion.driver_version,
					databaseProduct: dbVersion.database_productname,
					databaseVersion: dbVersion.database_version
				} ), true );

				expect( dbVersion.recordCount ).toBe( 1 );
				expect( dbVersion.database_productname ).toInclude( "HSQL" );
				expect( dbVersion.driver_version ).toInclude( variables.driverVersion );
				expect( dbVersion.database_version ).toInclude( variables.driverVersion );
			} );

			it( title="can create a table, insert and read rows", body=function( currentSpec ) {
				var ds = getDatasourceDefinition();

				query datasource=ds {
					echo( "CREATE TABLE ldev5262 ( id INT PRIMARY KEY, name VARCHAR(50) )" );
				}
				try {
					query datasource=ds {
						echo( "INSERT INTO ldev5262 ( id, name ) VALUES ( 1, 'lucee' ), ( 2, 'hsqldb' )" );
					}
					query datasource=ds name="local.qry" {
						echo( "SELECT id, name FROM ldev5262 ORDER BY id" );
					}
					expect( qry.recordCount ).toBe( 2 );
					expect( qry.name[ 1 ] ).toBe( "lucee" );
					expect( qry.name[ 2 ] ).toBe( "hsqldb" );

					// LISTAGG was added in HSQLDB 2.7.4
					query datasource=ds name="local.agg" {
						echo( "SELECT LISTAGG( name, ',' ) WITHIN GROUP ( ORDER BY id ) AS names FROM ldev5262" );
					}
					expect( agg.names ).toBe( "lucee,hsqldb" );
				}
				finally {
					query datasource=ds {
						echo( "DROP TABLE ldev5262" );
					}
				}
			} );

		} );
	}

}
