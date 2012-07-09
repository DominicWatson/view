<cfcomponent output="false">
	<!---
		The code in this component is geared to revealing as little as possible to the view.
		The view should only see:

			* a "loc" struct   (for local variables)
			* an "args" struct (a short alias to the arguments scope where data must be deliberately passed to the view)
	--->
	<cfscript>
		variables.request     = StructNew();
	</cfscript>

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="framework" type="any" required="true" />

		<cfscript>
			_setFramework( framework );

			StructDelete( this, "init" );

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="renderView" access="public" returntype="string" output="false">
		<cfargument name="__viewPath" type="string" required="true" />
		<cfargument name="__data"     type="struct" required="true" />

		<cfscript>
			var loc  = StructNew();
			var args = arguments.__data;

			loc.__state = serializeJson( variables );
		</cfscript>

		<cfsavecontent variable="loc.result">
			<cfinclude template="#__viewPath#" />
		</cfsavecontent>

		<cfif loc.__state NEQ serializeJson( variables )>
			<cfthrow type="view.scope.altered" message="Scope altered in view, '#Replace( ExpandPath( __viewPath ), '\', '/', 'all' )#'. To use variables local to your view, use the 'loc' scope." />
		</cfif>

		<cfreturn Trim( loc.result ) />
	</cffunction>

	<cffunction name="render" access="private" returntype="string" output="false">
		<cfargument name="view"   type="string" required="true"                          />
		<cfargument name="data"   type="struct" required="false" default="#StructNew()#" />
		<cfargument name="layout" type="string" required="false" default="none"          />

		<cfreturn _getFramework().render( argumentCollection = arguments ) />
	</cffunction>


<!--- accessors --->
	<cffunction name="_getFramework" access="private" returntype="any" output="false">
		<cfreturn _framework>
	</cffunction>
	<cffunction name="_setFramework" access="private" returntype="void" output="false">
		<cfargument name="framework" type="any" required="true" />
		<cfset _framework = arguments.framework />
	</cffunction>

</cfcomponent>