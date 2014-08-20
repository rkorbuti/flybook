
<%@ page import="flybook.Flight" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main">
		<g:set var="entityName" value="${message(code: 'flight.label', default: 'Flight')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#list-flight" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="list-flight" class="content scaffold-list" role="main">
			<h1><g:message code="default.list.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
				<div class="message" role="status">${flash.message}</div>
			</g:if>
			<table>
			<thead>
					<tr>
					
						<th><g:message code="flight.airport_from.label" default="Airportfrom" /></th>
					
						<th><g:message code="flight.airport_to.label" default="Airportto" /></th>
					
						<g:sortableColumn property="arrival_time" title="${message(code: 'flight.arrival_time.label', default: 'Arrivaltime')}" />
					
						<g:sortableColumn property="departure_time" title="${message(code: 'flight.departure_time.label', default: 'Departuretime')}" />
					
						<g:sortableColumn property="enabled" title="${message(code: 'flight.enabled.label', default: 'Enabled')}" />
					
						<g:sortableColumn property="price" title="${message(code: 'flight.price.label', default: 'Price')}" />
					
					</tr>
				</thead>
				<tbody>
				<g:each in="${flightInstanceList}" status="i" var="flightInstance">
					<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
					
						<td><g:link action="show" id="${flightInstance.id}">${fieldValue(bean: flightInstance, field: "airport_from")}</g:link></td>
					
						<td>${fieldValue(bean: flightInstance, field: "airport_to")}</td>
					
						<td><g:formatDate date="${flightInstance.arrival_time}" /></td>
					
						<td><g:formatDate date="${flightInstance.departure_time}" /></td>
					
						<td><g:formatBoolean boolean="${flightInstance.enabled}" /></td>
					
						<td>${fieldValue(bean: flightInstance, field: "price")}</td>
					
					</tr>
				</g:each>
				</tbody>
			</table>
			<div class="pagination">
				<g:paginate total="${flightInstanceCount ?: 0}" />
			</div>
		</div>
	</body>
</html>
