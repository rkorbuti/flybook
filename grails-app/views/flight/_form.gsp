<%@ page import="flybook.Flight" %>



<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'airportFrom', 'error')} required">
	<label for="airportFrom">
		<g:message code="flight.airportFrom.label" default="Airport From" />
		<span class="required-indicator">*</span>
	</label>
	<g:select id="airportFrom" name="airportFrom.id" from="${flybook.Airport.list()}" optionKey="id" required="" value="${flightInstance?.airportFrom?.id}" class="many-to-one"/>

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'airportTo', 'error')} required">
	<label for="airportTo">
		<g:message code="flight.airportTo.label" default="Airport To" />
		<span class="required-indicator">*</span>
	</label>
	<g:select id="airportTo" name="airportTo.id" from="${flybook.Airport.list()}" optionKey="id" required="" value="${flightInstance?.airportTo?.id}" class="many-to-one"/>

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'departureTime', 'error')} required">
	<label for="departureTime">
		<g:message code="flight.departureTime.label" default="Departure Time" />
		<span class="required-indicator">*</span>
	</label>
	<g:datePicker name="departureTime" precision="day"  value="${flightInstance?.departureTime}" relativeYears="[0..1]" />

</div>

<div class="fieldcontain ${hasErrors(bean: flightInstance, field: 'arrivalTime', 'error')} required">
	<label for="arrivalTime">
		<g:message code="flight.arrivalTime.label" default="Arrival Time" />
		<span class="required-indicator">*</span>
	</label>
	<g:datePicker name="arrivalTime" precision="day"  value="${flightInstance?.arrivalTime}" relativeYears="[0..1]" />

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

