<%
/*
 * Program name: Project - Streamline
 *
 * File Name: index.jsp
 * 
 * Developer: Lucas Brown, Russel Saenz, Kane Villareal, Chase Dennis, Carlos Glover, Trey Harrison
 * 
 * Date Created: 9/29/2024
 * 
 * Version: 5.0
 * 
 * Purpose: Initial startup file, sets the layout of the homepage. Displays the welcome message, the search bar linked to search.jsp, the "Get Recommendations" button linked to recommend.jsp, and the account buttons.
 * If the user is not logged into their account, the Login and Register buttons display, which link to login.jsp and register.jsp respectively.
 * If the user is logged into their account, the Login and Register buttons are replaced by a hello message and a Logout button that links back to this page.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<!-- Links to the style-sheets that determine the style and layout of the page -->
<link rel="stylesheet" type="text/css" href="styles/global.css"/>
<link rel="stylesheet" type="text/css" href="styles/home.css"/>
<head>
<meta charset="UTF-8">
<title>Streamline Homepage</title>
</head>
<body class="body">
	<!-- If the user clicked the Logout button -->
	<%if(request.getParameter("logout-clicked") != null){
		// Removes the userId and username from the session attribute container
		session.removeAttribute("userId");
		session.removeAttribute("username");
	}
	
	// If the user is logged in, displays the Hello message and the Logout button
	if(session.getAttribute("userId") != null){ %>
	<div class="account-button-container">
		<p class="hello-message">Hello <%=session.getAttribute("username") %></p>
		<form action="index.jsp">
			<input type="submit" class="logout-button" value="Logout">
			<input type="hidden" name="logout-clicked" value="logout-clicked">
		</form>
		<form action="UserLists.jsp">
			<input type="submit" class="watched-played-button" value="Watched/Played list">
		</form>
	</div>
	<!-- If the user is not logged in, displays the Login and Register buttons -->
	<%} else { %>
		<div class="account-button-container">
			<form action="login.jsp" class="account-button-form">
				<input type="submit" class="login-button" value="Login">
			</form>
			<form action="register.jsp" class="account-button-form">
				<input type="submit" class="register-button" value="Register">
			</form>
		</div>
	<%} %>
	<!-- Displays the Welcome message and application logo -->
	<div class="header-block">
		<h1 class="header">Welcome to<br>
		<span class="title">Stream<span style="color:var(--primary-color)">line</span></span></h1>
	</div>
	<!-- Block that contains the search bar, Search submit button, and the hidden drop-downs needed for search.jsp initialization -->
	<div class="search-block">
		<!--Form that sends to search.jsp-->
		<form action="search.jsp" class="search-form" method="get">
			<!-- Nested block that contains the search bar and Search submit button -->
			<div class="search-input-block">
				<input type="search" name="searchInput" class="search-bar" placeholder="Enter a movie or game">
				<input type="submit" class="search-button" value="Search">
			</div>
			<!--Drop down for sorting order (DROP DOWN IS HIDDEN, IT IS USED FOR A DEFAULT PARAMETER IN THE SEARCH) -->
			<select name="sort" style= display:none>
	            <option value="relevance" <%= "relevance".equals(request.getParameter("sort")) ? "selected" : "" %>>Relevance</option>         
	        </select>
	        
			<!--Drop down for type of media (game or movie or both.) (DROP DOWN IS HIDDEN, IT IS USED FOR A DEFAULT PARAMETER IN THE SEARCH) -->
			 <select name="type" style= display:none>
	            <option value="">Both Movies and Games</option>  
	        </select>
		</form>
	</div>
	<div>
		<h2 class="or-text">Or</h2>
	</div>
	<!--Button to send user to recommendation page -->
	<div class="recommendations-block">
		<form action="recommend.jsp" class="recommend-button">
			<input type="submit" value="Get Recommendations">
		</form>
	</div>
</body>
</html>