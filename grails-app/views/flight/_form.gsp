<%@ page import="flybook.Flight" %>



<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'airport_from', 'error')} required">
	<label for="airport_from">
		<g:message code="flight.airport_from.label" default="Airportfrom" />
		<span class="required-indicator">*</span>
	</label>
	<g:select id="airport_from" name="airport_from.id" from="${flybook.Airport.list()}" optionKey="id" required="" value="${flightInstance?.airport_from?.id}" class="many-to-one"/>

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'airport_to', 'error')} required">
	<label for="airport_to">
		<g:message code="flight.airport_to.label" default="Airportto" />
		<span class="required-indicator">*</span>
	</label>
	<g:select id="airport_to" name="airport_to.id" from="${flybook.Airport.list()}" optionKey="id" required="" value="${flightInstance?.airport_to?.id}" class="many-to-one"/>

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'arrival_time', 'error')} required">
	<label for="arrival_time">
		<g:message code="flight.arrival_time.label" default="Arrivaltime" />
		<span class="required-indicator">*</span>
	</label>
	<g:datePicker name="arrival_time" precision="day"  value="${flightInstance?.arrival_time}"  />

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'departure_time', 'error')} required">
	<label for="departure_time">
		<g:message code="flight.departure_time.label" default="Departuretime" />
		<span class="required-indicator">*</span>
	</label>
	<g:datePicker name="departure_time" precision="day"  value="${flightInstance?.departure_time}"  />

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'enabled', 'error')} ">
	<label for="enabled">
		<g:message code="flight.enabled.label" default="Enabled" />
		
	</label>
	<g:checkBox name="enabled" value="${flightInstance?.enabled}" />

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'price', 'error')} required">
	<label for="price">
		<g:message code="flight.price.label" default="Price" />
		<span class="required-indicator">*</span>
	</label>
	<g:field name="price" value="${fieldValue(bean: flightInstance, field: 'price')}" required=""/>

</div>

