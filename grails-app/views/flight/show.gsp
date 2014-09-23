
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
			
				<g:if test="${flightInstance?.airportFrom}">
				<li class="fieldcontain">
					<span id="airportFrom-label" class="property-label"><g:message code="flight.airportFrom.label" default="Airport From" /></span>
					
						<span class="property-value" aria-labelledby="airportFrom-label"><g:link controller="airport" action="show" id="${flightInstance?.airportFrom?.id}">${flightInstance?.airportFrom?.encodeAsHTML()}</g:link></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.airportTo}">
				<li class="fieldcontain">
					<span id="airportTo-label" class="property-label"><g:message code="flight.airportTo.label" default="Airport To" /></span>
					
						<span class="property-value" aria-labelledby="airportTo-label"><g:link controller="airport" action="show" id="${flightInstance?.airportTo?.id}">${flightInstance?.airportTo?.encodeAsHTML()}</g:link></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.departureTime}">
				<li class="fieldcontain">
					<span id="departureTime-label" class="property-label"><g:message code="flight.departureTime.label" default="Departure Time" /></span>
					
						<span class="property-value" aria-labelledby="departureTime-label"><g:formatDate date="${flightInstance?.departureTime}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${flightInstance?.arrivalTime}">
				<li class="fieldcontain">
					<span id="arrivalTime-label" class="property-label"><g:message code="flight.arrivalTime.label" default="Arrival Time" /></span>
					
						<span class="property-value" aria-labelledby="arrivalTime-label"><g:formatDate date="${flightInstance?.arrivalTime}" /></span>
					
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
