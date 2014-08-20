<%@ page import="flybook.Airport" %>



<div class="fieldcontain ${hasErrors(bean: airportInstance, field: 'code', 'error')} required">
	<label for="code">
		<g:message code="airport.code.label" default="Code" />
		<span class="required-indicator">*</span>
	</label>
	<g:textField name="code" maxlength="3" required="" value="${airportInstance?.code}"/>

</div>

<div class="fieldcontain ${hasErrors(bean: airportInstance, field: 'city', 'error')} required">
	<label for="city">
		<g:message code="airport.city.label" default="City" />
		<span class="required-indicator">*</span>
	</label>
	<g:select id="city" name="city.id" from="${flybook.City.list()}" optionKey="id" required="" value="${airportInstance?.city?.id}" class="many-to-one"/>

</div>

