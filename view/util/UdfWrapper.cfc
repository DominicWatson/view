<cfcomponent output="false" extends="Base">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="udfDirs" type="string" required="true" />

		<cfscript>
			_loadUdfs( udfDirs );

			StructDelete( this, "init" );

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="_loadUdfs" access="private" returntype="void" output="false">
		<cfargument name="udfDirs" type="string" required="true" />

		<cfscript>
			var i = 0;
			var n = 0;
			var udfPath = "";
			var udfFiles = "";
			var udfFile = "";

			for( i=1; i LTE ListLen( udfDirs ); i++ ){
				udfPath = ListGetAt( udfDirs, i );
				udfFiles = $directoryList( udfPath, "*.cfm" );
				for( n=1; n LTE udfFiles.recordCount; n++ ){
					udfFile = $normalizeUnixAndWindowsPaths( $listAppend( udfFiles.directory[n], udfFiles.name[n], "/" ) );
					_include( udfFile );
				}
			}

			_makeIncludedMethodsPublic();
		</cfscript>
	</cffunction>

	<cffunction name="_include" access="private" returntype="void" output="false">
		<cfargument name="fullPath" type="string" required="true" />

		<cfscript>
			var thisPath = getCurrentTemplatePath();
			var relPath  = $calculateRelativePath( thisPath, fullPath );
		</cfscript>

		<cfinclude template="#relPath#" />
	</cffunction>

	<cffunction name="_makeIncludedMethodsPublic" access="private" returntype="void" output="false">
		<cfscript>
			var i = 0;
			var keys = StructKeyArray( variables );

			for( i=1; i LTE ArrayLen( keys ); i++ ){
				if ( not StructKeyExists( this, keys[i] ) and keys[i] neq "this" ) {
					this[ keys[i] ] = variables[ keys[i] ];
				}
			}
		</cfscript>
	</cffunction>

</cfcomponent>