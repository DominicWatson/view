<cfcomponent output="false" extends="util.Base">

	<cfscript>
		_views    = StructNew();
		_viewPath = "";
	</cfscript>

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="viewPath" type="string" required="true" />

		<cfscript>
			_setViewPath( viewPath );
			_initViewRenderer();
			_loadViews();

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="render" access="public" returntype="string" output="false">
		<cfargument name="view" type="string" required="true"                          />
		<cfargument name="data" type="struct" required="false" default="#StructNew()#" />

		<cfscript>
			var path   = _getView( view ).path;
			var result = "";

			data['__viewPath'] = path;
			result = _getViewRenderer().render( argumentCollection = data );
			StructDelete( data, '__viewPath' );

			return result;
		</cfscript>
	</cffunction>

<!--- private --->
	<cffunction name="_loadViews" access="private" returntype="void" output="false">
		<cfscript>
			var files    = $directoryList( _getViewPath(), "*.cfm" );
			var filePath = "";
			var views    = StructNew();
			var view     = "";
			var i        = "";

			for( i=1; i LTE files.recordCount; i++ ){
				filePath      = $listAppend( files.directory[i], files.name[i], '/' );
				view          = _convertFullViewPathToViewName( filePath );
				views[ view ] = StructNew();
				views[ view ].path = filePath;
			}

			_setViews( views );
		</cfscript>
	</cffunction>

	<cffunction name="_getView" access="private" returntype="struct" output="false">
		<cfargument name="view" type="string" required="true" />

		<cfscript>
			var views = _getViews();

			if ( StructKeyExists( views, view ) ) {
				return views[ view ];
			}

			// todo: throw error
		</cfscript>
	</cffunction>

	<cffunction name="_convertFullViewPathToViewName" access="private" returntype="string" output="false">
		<cfargument name="fullPath" type="string" required="true" />

		<cfscript>
			var viewPath = _getViewPath();
			var viewName = fullPath;

			viewName = Replace( viewName, viewPath, "" );
			viewName = ListChangeDelims( viewName, ".", "/" );
			viewName = Left( viewName, Len(viewName) - 4 );

			return viewName;
		</cfscript>
	</cffunction>

	<cffunction name="_initViewRenderer" access="private" returntype="void" output="false">
		<cfscript>
			var vr = CreateObject( "component", "util.ViewRenderer" );
			_setViewRenderer( vr );
		</cfscript>
	</cffunction>

<!--- accessors --->
	<cffunction name="_getViews" access="private" returntype="struct" output="false">
		<cfreturn _views>
	</cffunction>
	<cffunction name="_setViews" access="private" returntype="void" output="false">
		<cfargument name="views" type="struct" required="true" />
		<cfset _views = views />
	</cffunction>

	<cffunction name="_getViewPath" access="private" returntype="string" output="false">
		<cfreturn _viewPath>
	</cffunction>
	<cffunction name="_setViewPath" access="private" returntype="void" output="false">
		<cfargument name="viewPath" type="string" required="true" />
		<cfset _viewPath = $normalizeUnixAndWindowsPaths( $ensureFullDirectoryPath( viewPath ) ) />
	</cffunction>

	<cffunction name="_getViewRenderer" access="private" returntype="any" output="false">
		<cfreturn _viewRenderer>
	</cffunction>
	<cffunction name="_setViewRenderer" access="private" returntype="void" output="false">
		<cfargument name="viewRenderer" type="any" required="true" />
		<cfset _viewRenderer = arguments.viewRenderer />
	</cffunction>
</cfcomponent>