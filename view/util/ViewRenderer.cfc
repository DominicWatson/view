<cfcomponent output="false">

	<!---
		The code in this component is geared to revealing as little as possible to the view.
		The view should only see:

			* a "loc" struct   (for local variables)
			* an "args" struct (a short alias to the arguments scope where data must be deliberately passed to the view)
	--->
	<cffunction name="render" access="public" returntype="string" output="false">
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

</cfcomponent>