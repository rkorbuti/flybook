<%--
  Created by IntelliJ IDEA.
  User: sten
  Date: 28.09.2014
  Time: 21:12
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title><g:message message = "Get Flights" /></title>
</head>

<body>
<div class="nav" role="navigation">
    <ul>
        <li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
    </ul>
</div>
<table>
    <thead>
    <tr>

        <th><g:message code="flight.airportFrom.label" default="Airport From" /></th>

        <th><g:message code="flight.airportTo.label" default="Airport To" /></th>

        <g:sortableColumn property="departureTime" title="${message(code: 'flight.departureTime.label', default: 'Departure Time')}" />

        <g:sortableColumn property="arrivalTime" title="${message(code: 'flight.arrivalTime.label', default: 'Arrival Time')}" />

        <g:sortableColumn property="enabled" title="${message(code: 'flight.enabled.label', default: 'Enabled')}" />

        <g:sortableColumn property="price" title="${message(code: 'flight.price.label', default: 'Price')}" />

    </tr>
    </thead>
    <tbody>
        <g:if test="${to != null}">
            <g:each in="${list}" status="i" var="flight">
                <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                    <td><a href = ${flightUrl + flight[3]} target = "_blank">${from}</a></td>

                    <td>${to}</td>

                    <td>${flight[0]}</td>

                    <td>${flight[1]}</td>

                    <td></td>

                    <td>${flight[2]}</td>

                </tr>
            </g:each>
        </g:if>
        <g:else>
            <g:each in="${list}" status="i" var="flight">
                <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                    <td><a href = ${flight[4]} target = "_blank">${from}</a></td>

                    <td>${flight[0]}</td>

                    <td>${flight[1]}</td>

                    <td>${flight[2]}</td>

                    <td></td>

                    <td>${flight[3]}</td>

                </tr>
            </g:each>
        </g:else>
    </tbody>
</table>
</body>
</html>