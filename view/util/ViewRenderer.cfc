<cfcomponent output="false">
<!--- properties --->
	<cfscript>
		variables.request     = StructNew();
	</cfscript>

<!--- constructor --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="framework" type="any" required="true" />

		<cfscript>
			_setFramework( framework );

			StructDelete( this, "init" );

			return this;
		</cfscript>
	</cffunction>

<!--- public methods --->
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
			<cfthrow type="view.scope.altered" message="Scope altered in view, '#ListLast( __viewPath, '/' )#'. To use variables local to your view, use the 'loc' scope." />
		</cfif>

		<cfreturn Trim( loc.result ) />
	</cffunction>

<!--- private methods --->
	<cffunction name="render" access="private" returntype="string" output="false">
		<cfargument name="view"   type="string" required="true"                          />
		<cfargument name="data"   type="struct" required="false" default="#StructNew()#" />

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