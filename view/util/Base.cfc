<cfcomponent output="false" hint="I am a base class providing common utility methods for all components. All CfStatic components extend me">

	<cffunction name="$throw" access="private" returntype="void" output="false" hint="I throw an error">
		<cfargument name="type"			type="string" required="false" default="CfMinify.error" />
		<cfargument name="message"		type="string" required="false" />
		<cfargument name="detail"		type="string" required="false" />
		<cfargument name="errorCode"	type="string" required="false" />
		<cfargument name="extendedInfo"	type="string" required="false" />

		<cfthrow attributeCollection="#arguments#" />
	</cffunction>

	<cffunction name="$directoryList" access="private" returntype="query" output="false" hint="I return a query of files and subdirectories for a given directory">
		<cfargument name="directory"	type="string" required="true"					/>
		<cfargument name="filter"		type="string" required="false"	default="*.*"	/>
		<cfargument name="recurse"		type="boolean" required="false"	default="true"	/>

		<cfset var result = QueryNew('') />

		<cfif DirectoryExists( arguments.directory )>
			<cfdirectory	action="list"
							directory="#arguments.directory#"
							filter="#arguments.filter#"
							recurse="#arguments.recurse#"
							name="result" />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="$fileRead" access="private" returntype="string" output="false" hint="I return the content of the given file (path)">
		<cfargument name="path" type="string" required="true" />

		<cfset var content = "" />
		<cffile action="read" file="#arguments.path#" variable="content" />
		<cfreturn content />
	</cffunction>

	<cffunction name="$reSearch" access="private" returntype="struct" output="false" hint="I perform a Regex search and return a struct of arrays containing pattern match information. Each key represents the position of a match, i.e. $1, $2, etc. Each key contains an array of matches.">
		<cfargument name="regex"	type="string"	required="true" />
		<cfargument name="text"		type="string"	required="true" />

		<cfscript>
			var final 	= StructNew();
			var pos		= 1;
			var result	= ReFindNoCase( arguments.regex, arguments.text, pos, true );
			var i		= 0;

			while( ArrayLen(result.pos) GT 1 ) {
				for(i=2; i LTE ArrayLen(result.pos); i++){
					if(not StructKeyExists(final, '$#i-1#')){
						final['$#i-1#'] = ArrayNew(1);
					}
					if ( result.pos[i] ) {
						ArrayAppend(final['$#i-1#'], Mid(arguments.text, result.pos[i], result.len[i]));
					} else {
						ArrayAppend(final['$#i-1#'], "");
					}
				}
				pos = result.pos[2] + 1;
				result	= ReFindNoCase( arguments.regex, arguments.text, pos, true );
			} ;

			return final;
		</cfscript>
	</cffunction>

	<cffunction name="$listAppend" access="private" returntype="string" output="false" hint="I override listAppend, ensuring that, when a list already contains its delimiter at the end, a duplicate delimiter is not appended">
		<cfargument name="list" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfargument name="delimiter" type="string" required="false" default="," />

		<cfscript>
			var delimiterAlreadyOnEnd = Right( arguments.list, Len( arguments.delimiter ) ) eq arguments.delimiter;
			var isEmptyList           = not Len( arguments.list );

			if ( delimiterAlreadyOnEnd or isEmptyList ) {
				return arguments.list & arguments.value;
			}

			return arguments.list & arguments.delimiter & arguments.value;
		</cfscript>
	</cffunction>

	<cffunction name="$normalizeUnixAndWindowsPaths" access="private" returntype="string" output="false">
		<cfargument name="path" type="string" required="true" />

		<cfreturn Replace( arguments.path, '\', '/', 'all' ) />
	</cffunction>

	<cffunction name="$calculateRelativePath" access="private" returntype="string" output="false">
		<cfargument name="basePath"     type="string" required="true" />
		<cfargument name="relativePath" type="string" required="true" />

		<cfscript>
			var basePathArray     = ListToArray( GetDirectoryFromPath( arguments.basePath ), "\/" );
			var relativePathArray = ListToArray( arguments.relativePath, "\/" );
			var finalPath         = ArrayNew(1);
			var pathStart         = 0;
			var i                 = 0;

			/* Define the starting path (path in common) */
			for (i = 1; i LTE ArrayLen(basePathArray); i = i + 1) {
				if (basePathArray[i] NEQ relativePathArray[i]) {
					pathStart = i;
					break;
				}
			}

			if ( pathStart EQ 0 ) {
				ArrayAppend( finalPath, "." );
				pathStart = ArrayLen(basePathArray);
			}

			/* Build the prefix for the relative path (../../etc.) */
			for ( i = ArrayLen(basePathArray) - pathStart; i GTE 0; i=i-1 ) {
				ArrayAppend( finalPath, ".." );
			}

			/* Build the relative path */
			for ( i = pathStart; i LTE ArrayLen(relativePathArray); i=i+1 ) {
				ArrayAppend( finalPath, relativePathArray[i] );
			}

			return ArrayToList( finalPath, "/" );
		</cfscript>
	</cffunction>

	<cffunction name="$ensureFullDirectoryPath" access="private" returntype="string" output="false">
		<cfargument name="dir" type="string" required="true" />
		<cfscript>
			if ( directoryExists( ExpandPath( arguments.dir ) ) ) {
				return ExpandPath( arguments.dir );
			}
			return arguments.dir;
		</cfscript>
	</cffunction>

</cfcomponent>