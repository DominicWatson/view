<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="viewPath" type="string" required="true" />

		<cfscript>
			_setViewPath( viewPath );
			_loadViews();

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="render" access="public" returntype="string" output="false">
		<cfreturn "" />
	</cffunction>

<!--- private --->
	<cffunction name="_loadViews" access="private" returntype="void" output="false">
	</cffunction>

<!--- accessors --->
	<cffunction name="_getViewPath" access="private" returntype="string" output="false">
		<cfreturn _viewPath>
	</cffunction>
	<cffunction name="_setViewPath" access="private" returntype="void" output="false">
		<cfargument name="viewPath" type="string" required="true" />
		<cfset _viewPath = arguments.viewPath />
	</cffunction>
</cfcomponent>