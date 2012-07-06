<cfcomponent output="false" extends="util.Base">

	<cffunction name="render" access="public" returntype="string" output="false">
		<cfargument name="__viewPath" type="string" required="true" />

		<cfscript>
			var _$sortaPrivate$_ = StructNew();
			var loc      = StructNew();
			var args     = _prepareArgs( arguments );

			_$sortaPrivate$_.viewPath = $calculateRelativePath( getCurrentTemplatePath(), __viewPath );
			_$sortaPrivate$_.result   = "";

			StructClear( arguments );
		</cfscript>

		<cfsavecontent variable="_$sortaPrivate$_.result">
			<cfinclude template="#_$sortaPrivate$_.viewPath#" />
		</cfsavecontent>

		<cfreturn Trim( _$sortaPrivate$_.result ) />
	</cffunction>

	<cffunction name="_prepareArgs" access="private" returntype="struct" output="false">
		<cfargument name="args" type="struct" required="true" />

		<cfscript>
			var newArgs = StructNew();
			var keys    = StructKeyArray( args );
			var i       = 0;

			for( i=1; i lte ArrayLen( keys ); i++ ){
				if ( keys[i] neq "__viewPath" ) {
					newArgs[ keys[i] ] = args[ keys[i] ];
				}
			}

			return newArgs;
		</cfscript>
	</cffunction>
</cfcomponent>