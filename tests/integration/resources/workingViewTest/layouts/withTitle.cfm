<cfparam name="args.body" default="" type="string" />
<cfparam name="args.pageTitle" type="string" />

<cfoutput>
	<div id="anotherlayout"><h1>#args.pageTitle#</h1>#args.body#</div>
</cfoutput>