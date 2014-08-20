
<%@ page import="flybook.Flight" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main">
		<g:set var="entityName" value="${message(code: 'flight.label', default: 'Flight')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#show-flight" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="show-flight" class="content scaffold-show" role="main">
			<h1><g:message code="default.show.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<ol class="property-list flight">
			
				<g:if test="${flightInstance?.airport_from}">
				<li class="fieldcontain">
					<span id="airport_from-label" class="property-label"><g:message code="flight.airport_from.label" default="Airportfrom" /></span>
					
						<span class="property-value" aria-labelledby="airport_from-label"><g:link controller="airport" action="show" id="${flightInstance?.airport_from?.id}">${flightInstance?.airport_from?.encodeAsHTML()}</g:link></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.airport_to}">
				<li class="fieldcontain">
					<span id="airport_to-label" class="property-label"><g:message code="flight.airport_to.label" default="Airportto" /></span>
					
						<span class="property-value" aria-labelledby="airport_to-label"><g:link controller="airport" action="show" id="${flightInstance?.airport_to?.id}">${flightInstance?.airport_to?.encodeAsHTML()}</g:link></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.arrival_time}">
				<li class="fieldcontain">
					<span id="arrival_time-label" class="property-label"><g:message code="flight.arrival_time.label" default="Arrivaltime" /></span>
					
						<span class="property-value" aria-labelledby="arrival_time-label"><g:formatDate date="${flightInstance?.arrival_time}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.departure_time}">
				<li class="fieldcontain">
					<span id="departure_time-label" class="property-label"><g:message code="flight.departure_time.label" default="Departuretime" /></span>
					
						<span class="property-value" aria-labelledby="departure_time-label"><g:formatDate date="${flightInstance?.departure_time}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.enabled}">
				<li class="fieldcontain">
					<span id="enabled-label" class="property-label"><g:message code="flight.enabled.label" default="Enabled" /></span>
					
						<span class="property-value" aria-labelledby="enabled-label"><g:formatBoolean boolean="${flightInstance?.enabled}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.price}">
				<li class="fieldcontain">
					<span id="price-label" class="property-label"><g:message code="flight.price.label" default="Price" /></span>
					
						<span class="property-value" aria-labelledby="price-label"><g:fieldValue bean="${flightInstance}" field="price"/></span>
					
				</li>
				</g:if>
			
			</ol>
			<g:form url="[resource:flightInstance, action:'delete']" method="DELETE">
				<fieldset class="buttons">
					<g:link class="edit" action="edit" resource="${flightInstance}"><g:message code="default.button.edit.label" default="Edit" /></g:link>
					<g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
				</fieldset>
			</g:form>
		</div>
	</body>
</html>
