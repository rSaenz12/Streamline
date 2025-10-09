<%
/*
 * Program name: Project - Streamline
 *
 * File Name: login.jsp
 * 
 * Developer: Lucas Brown, Russel Saenz, Kane Villareal, Chase Dennis, Carlos Glover, Trey Harrison
 * 
 * Date Created: 9/29/2024
 * 
 * Version: 5.0
 * 
 * Purpose: Displays the login page that allows the user to log into their account. Displays the Login title, labels and text inputs for the username and password entry,
 * 			as well as the Login button that links to the same page, and Continue as guest button that links back to index.jsp.
 *			If the user enters valid account information and clicks log in, the page reloads, and only displays the Login successfull message and the Return to Homepage
 *			button that links to index.jsp.
 * 			If the user enters invalid account information and clicks log in, the page reloads and displays the default login page but with an "Invalid username or password" message.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page import="java.sql.*"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Login to Streamline</title>
	<!-- Links to the style-sheets that determine the style and layout of the page -->
	<link rel="stylesheet" type="text/css" href="styles/global.css"/>
	<link rel="stylesheet" type="text/css" href="styles/login.css"/>
</head>
<body class="body">
<%
	// If the user clicked the Login button on this page, only form that submits to this page via "POST" is the Login button on this page.
	if(request.getMethod().equalsIgnoreCase("POST")){
		// Gets the user's input to the username and password text fields
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		// Trys to connect to the database
		 try {
			 // Connects to the database
             Class.forName("com.mysql.cj.jdbc.Driver");
             Connection conn = DriverManager.getConnection(/*DB Key*/);
             // Initializes the SQL query string to pull the users account information from the database
             String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
             PreparedStatement stmt = conn.prepareStatement(sql);
             stmt.setString(1, username);
             stmt.setString(2, password);
             // Executes the SQL query
             ResultSet rs = stmt.executeQuery();
			 
             // If the user account info is valid. Will only be true if the SQL query to the database returns an account row.
             if (rs.next()) {%>
             	<h1>Login Successful</h1>
             	<!-- Return to Homepage button, returns to index.jsp -->
             	<div class="main-block">
	             	<form action="index.jsp" method="get">
	             		<input type="submit" value="Return to Homepage">
	             	</form>
             	</div>
             	<!-- Places the userId and username retrieved from the database into the session attribute container -->
                 <%
                 session.setAttribute("userId", rs.getInt(1));
                 session.setAttribute("username", rs.getString(2));
             } else {%>
             <!-- Block that contains the Login title, Invalid account info message, username label and text input, and the password label and text input -->
             <div class="main-block">
             	<!-- Form that submits the username and password info to this page -->
             	<form id="loginForm" class="login-form"action="login.jsp" method="POST">
             			<!-- Nested block that contains the Login title and invalid account info message -->
		                 <div class="login-title-block">
					   		<h1>Login</h1>
					   		<p>Invalid username or password. Please try again</p>
					   	</div>
					   	<!-- Nested block, contains the username label and text input -->
                	   	<div class="username-field-block">
					   		<span class="username-field-label">Username:</span>
					   		<input type="text" class="input-field" name="username">
					   	</div>
					   	<!-- Nested block, contains the password label and text input -->
					   	<div class="password-field-block">
					   		<span class="password-field-label">Password:</span>
					   		<input type="password" class="input-field" name="password">
					   	</div>
					   	<!-- Nested block, contains the Login submit button -->
					   	<div class="submit-button-block">
					   		<input type="submit" value="Login">
					   	</div>
				</form>
				</div>
				<!-- Block that contains the Continue as Guest button that sends user back to index.jsp -->
				<div class="submit-button-block">
				   	<form action="index.jsp" method="get">
				   			<input type="submit" value="Continue as Guest">
				   	</form>
				</div>
             <%}
             // Closes the connection to the database
             conn.close();
		// If an error is found when connecting to the mySQL database
         }catch (SQLException e) {
 			e.printStackTrace();
 			out.println("Connection failed: " + e.getMessage());
 		}
	// If the login.jsp page was loaded from a different page, form was not submitted via "POST"
	} else {
%>
<!-- Block that contains the Login title, username label and text input, and the password label and text input -->
<div class="main-block">
	<!-- Form that submits the username and password info to this page -->
	<form id="loginForm" class="login-form"action="login.jsp" method="POST">
		<!-- Nested block that contains the Login title and invalid account info message -->
		<div class="login-title-block">
	   		<h1>Login</h1>
	   	</div>
	   	<!-- Nested block, contains the username label and text input -->
	   	<div class="username-field-block">
	   		<span class="username-field-label">Username:</span>
	   		<input type="text" class="input-field" name="username">
	   	</div>
	   	<!-- Nested block, contains the password label and text input -->
	   	<div class="password-field-block">
	   		<span class="password-field-label">Password:</span>
	   		<input type="password" class="input-field" name="password">
	   	</div>
	   	<!-- Nested block, contains the Login submit button -->
	   	<div class="submit-button-block">
	   		<input type="submit" value="Login">
	   	</div>
   	</form>
</div>
<!-- Block that contains the Continue as Guest button that sends user back to index.jsp -->
<div class="submit-button-block">
  	<form action="index.jsp" method="get">
  			<input type="submit" value="Continue as Guest">
  	</form>
</div>
<%	} %>
</body>
</html>