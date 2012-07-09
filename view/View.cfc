<cfcomponent output="false" extends="util.Base">

	<cfscript>
		_views     = StructNew();
		_viewPaths = ArrayNew(1);
	</cfscript>

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="viewPaths" type="string" required="true" />

		<cfscript>
			_setViewPaths( viewPaths );
			_initViewRenderer();
			_loadViews();

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="render" access="public" returntype="string" output="false">
		<cfargument name="view" type="string" required="true"                          />
		<cfargument name="data" type="struct" required="false" default="#StructNew()#" />

		<cfscript>
			var view = _getView( view );
			var args = StructNew();
			var i    = "";

			for( i=1; i LTE ArrayLen( view.args ); i++ ) {
				if ( StructKeyExists( data, view.args[i] ) ) {
					args[ view.args[i] ] = data[ view.args[i] ];
				}
			}

			return _getViewRenderer().renderView(
				  __viewPath = view.path
				, __data     = args
			);
		</cfscript>
	</cffunction>

<!--- private --->
	<cffunction name="_loadViews" access="private" returntype="void" output="false">
		<cfscript>
			var viewPaths = _getViewPaths();
			var files    = "";
			var filePath = "";
			var views    = StructNew();
			var view     = "";
			var i        = "";
			var n        = "";

			for( i=1; i LTE ArrayLen( viewPaths ); i++ ){
				files = $directoryList( viewPaths[i], "*.cfm" )

				for( n=1; n LTE files.recordCount; n++ ){
					filePath      = $listAppend( files.directory[n], files.name[n], '/' );

					_checkViewConformsToStrictRules( filePath );

					view          = _convertFullViewPathToViewName( filePath, viewPaths[i] );
					views[ view ] = StructNew();
					views[ view ].path = _convertFullPathToRelativePathForCfInclude( filePath );
					views[ view ].args = _parseArgsFromCfParam( filePath );
				}
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

			$throw( "view.notfound", "View not found. The view, '#view#', could not be found." );
		</cfscript>
	</cffunction>

	<cffunction name="_convertFullViewPathToViewName" access="private" returntype="string" output="false">
		<cfargument name="fullPath" type="string" required="true" />
		<cfargument name="viewPath" type="string" required="true" />

		<cfscript>
			var viewName = fullPath;

			viewName = Replace( viewName, viewPath, "" );
			viewName = ListChangeDelims( viewName, ".", "/" );
			viewName = Left( viewName, Len(viewName) - 4 );

			return viewName;
		</cfscript>
	</cffunction>

	<cffunction name="_convertFullPathToRelativePathForCfInclude" access="private" returntype="any" output="false">
		<cfargument name="fullPath" type="string" required="true" />

		<cfscript>
			var basePath = $listAppend( GetDirectoryFromPath( GetCurrentTemplatePath() ), 'util/ViewRenderer.cfc', '/' );

			return $calculateRelativePath( basePath, fullPath );
		</cfscript>
	</cffunction>

	<cffunction name="_parseArgsFromCfParam" access="private" returntype="array" output="false">
		<cfargument name="filePath" type="string" required="true" />

		<cfscript>
			var fileContent = $fileRead( filePath );
			var regex       = '<cfparam name="args\.(.*?)"';
			var regexResult = $research( regex, fileContent );

			if ( StructKeyExists( regexResult, "$1" ) ) {
				return regexResult.$1;
			}

			return ArrayNew(1);
		</cfscript>
	</cffunction>

	<cffunction name="_initViewRenderer" access="private" returntype="void" output="false">
		<cfscript>
			var vr = CreateObject( "component", "util.ViewRenderer" ).init( framework = this );
			_setViewRenderer( vr );
		</cfscript>
	</cffunction>

	<cffunction name="_checkViewConformsToStrictRules" access="private" returntype="void" output="false">
		<cfargument name="filePath" type="string" required="true" />

		<cfscript>
			var fileContent = $fileRead( filePath );
			// TODO: do this properly, full regex and line parsing
			var hasRequestScopeReferences = ReFindNoCase( "request[\[\.]", fileContent );

			if ( hasRequestScopeReferences ) {
				$throw(
					  type = "view.scope.notAllowed"
					, message = "A view attempted to use the request scope, this is not allowed in the View framework. The offending view was #filePath#."
				);
			}

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

	<cffunction name="_getViewPaths" access="private" returntype="array" output="false">
		<cfreturn _viewPaths />
	</cffunction>
	<cffunction name="_setViewPaths" access="private" returntype="void" output="false">
		<cfargument name="viewPaths" type="string" required="true" />

		<cfscript>
			var i = 0;

			_viewPaths = ListToArray( viewPaths );

			for( i=1; i LTE ArrayLen( _viewPaths ); i++ ){
				_viewPaths[i] = $normalizeUnixAndWindowsPaths( $ensureFullDirectoryPath( _viewPaths[i] ) );
			}
		</cfscript>
	</cffunction>

	<cffunction name="_getViewRenderer" access="private" returntype="any" output="false">
		<cfreturn _viewRenderer>
	</cffunction>
	<cffunction name="_setViewRenderer" access="private" returntype="void" output="false">
		<cfargument name="viewRenderer" type="any" required="true" />
		<cfset _viewRenderer = arguments.viewRenderer />
	</cffunction>
</cfcomponent>