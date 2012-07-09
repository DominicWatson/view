<cfparam name="args.someVar" type="string" default="This is a default" />

<cfoutput>#render( view="someFolder.aView", data=args )#</cfoutput>