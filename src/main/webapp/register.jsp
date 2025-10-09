<%
/*
 * Program name: Project - Streamline
 *
 * File Name: register.jsp
 * 
 * Developer: Lucas Brown, Russel Saenz, Kane Villareal, Chase Dennis, Carlos Glover, Trey Harrison
 * 
 * Date Created: 9/29/2024
 * 
 * Version: 5.0
 * 
 * Purpose: Displays the register page that allows the user to register for an account. Displays the Register title, labels and text inputs
 * 			for the username, email, and password, as well as a Confirm Password entry, the Register button that links to the same page, and 
 *			the Continue as Guest button that links back to index.jsp.
 *			If the user enters valid account information and clicks "Register", the page reloads and only displays the Registration successful
 *			message as well as the Continue to Login button that links to login.jsp, and the Return to Homepage button that links to index.jsp
 *			If the user enters invalid account information and clicks "Register", the page reloads and displays the default register page, but
 *			with a "Registration failed." message.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.regex.*" %>
<html>
<head>
<meta charset="UTF-8">
<title>Streamline - Register</title>
	<!-- Links to the style-sheets that determine the style and layout of the page -->
	<link rel="stylesheet" type="text/css" href="styles/global.css"/>
	<link rel="stylesheet" type="text/css" href="styles/register.css"/>
</head>
<body class="body">
<%!
String validateUserInput(String username, String email, String password, String confirmPassword){
	// Regular expression patterns used to check the user input for invalid characters
	String usernameAndPasswordRegexPattern = ".*[@#$%^&*\\(\\)\\+=\\[\\]{};:'\"\\\\|,.<>?/~].*";
	String emailRegexPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
	Pattern pattern = Pattern.compile(usernameAndPasswordRegexPattern);
	Matcher matcher = pattern.matcher(username);
	if(username.length() < 6){
		return "Username must be atleast 6 characters. Please try again.";
	}
	// Tests the username for invalid characters
	if(matcher.find()){
		return "Username contains invalid characters. Please try again.";
	}
	// Changes the pattern to validate email input
	pattern = Pattern.compile(emailRegexPattern);
	matcher = pattern.matcher(email);
	// Tests the email for valid format
	if(!matcher.find()){
		return "Email is invalid. Please try again.";
	}
	// Changes the pattern to validate password input
	pattern = Pattern.compile(usernameAndPasswordRegexPattern);
	matcher = pattern.matcher(password);
	if(password.length() < 6 || password.length() > 20){
		return "Password length must be between 6-20 characters. Please try again.";
	}
	// Tests the password for invalid characters
	if(matcher.find()){
		return "Password contains invalid characters. Please try again.";
	}
	System.out.println(password);
	System.out.println(confirmPassword);
	System.out.println(password.equals(confirmPassword));
	// Makes sure the password and confirm password inputs match
	if(!password.equals(confirmPassword)){
		return "Password and Confirm Password entries do not match. Please try again.";
	}
	return "valid";
}
%>
<%
// If the user clicked the Register button on this page, only form that submits to this page via "POST" is the Register button on this page.
if (request.getMethod().equalsIgnoreCase("POST")) {
	// Objects needed to get the current timestamp for account creation logging purposes
	LocalDateTime now = LocalDateTime.now();
	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
	// Randomizer object, used to get a randomized ID.
	Random random = new Random();
	
    // Generates the userId
    int id = random.nextInt(100000);
    // Gets the user's input to the username, email, and password text fields
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm-password");
    String validationResults = validateUserInput(username, email, password, confirmPassword);
    if(validationResults.equals("valid")){
	    // Gets the current timestamp
	    String timestamp = now.format(formatter);
	    try {
	        // Load the MySQL driver
	        Class.forName("com.mysql.cj.jdbc.Driver");
	
	        // Establish a database connection
	        Connection conn = DriverManager.getConnection(
	            /*DB Key*/
	        ); 
	
	        // Create an SQL query to insert the user data into the database
	        String sql = "INSERT INTO user (ID, username, email, password, create_time) VALUES (?, ?, ?, ?, ?)";
	
	        // Use a PreparedStatement to avoid SQL injection
	        PreparedStatement stmt = conn.prepareStatement(sql);
	        stmt.setInt(1, id);
	        stmt.setString(2, username);
	        stmt.setString(3, email);
	        stmt.setString(4, password);
	        stmt.setString(5, timestamp);
	        
	        // Execute the SQL query, attempting to insert the account information into the database
	        int rowsInserted = stmt.executeUpdate();
	
	        // If the account information was successfully inserted into the database.
	        if (rowsInserted > 0) {%>
				<h1>Registration Successful</h1>
					<!-- Block that contains the Continue to Login and Return to Homepage buttons -->
	             	<div class="main-block">
	             		<!-- Form that submits to login.jsp, contains the Continue to Login submit button -->
	             		<form action="login.jsp" method="get">
	             			<input type="submit" value="Continue to Login">
	             		</form>
	             		<!-- Form that submits to index.jsp, contains the Return to Homepage submit button -->
		             	<form action="index.jsp" method="get">
		             		<input type="submit" value="Return to Homepage">
		             	</form>
	             	</div>
	        <!-- If the account information was not inserted successfully -->
	        <% } else {%>
	        	<!-- Block that contains the Register title, Registration failed message, label and text fields for
	        		 username, email, password, and confirm password, as well as the Register button -->
	            <div class="main-block">
	            	<!-- Form that submits to this page, passing the user inputs from the text fields -->
					<form id="registerForm" class="register-form" action="register.jsp" method="POST">
						<!-- Nested block, contains the Register title and Registration failed message -->
					   	<div class="login-title-block">
					   		<h1>Register</h1>
					   		<p>Registration failed. Pleas try again.</p>
					   	</div>
					   	<!-- Nested Block, contains the username label and text field -->
					   	<div class="username-field-block">
					   		<span class="username-field-label">Username:</span>
					   		<input type="text" class="input-field" name="username">
					   	</div>
					   	<!-- Nested Block, contains the email label and text field -->
					   	<div class="email-field-block">
					   		<span class="email-field-label">Email:</span>
					   		<input type="text" class="input-field" name="email">
					   	</div>
					   	<!-- Nested Block, contains the password label and text field -->
					   	<div class="password-field-block">
					   		<span class="password-field-label">Password:</span>
					   		<input type="password" class="input-field" name="password">
					   	</div>
					   	<!-- Nested Block, contains the password label and text field -->
					   	<div class="confirm-password-field-block">
					   		<span class="confirm-password-field-label">Confirm Password:</span>
					   		<input type="password" class="input-field" name="confirm-password">
					   	</div>
					   	<!-- Nested Block, contains the Register submit button -->
					   	<div class="submit-button-block">
					   		<input type="submit" value="Register">
					   	</div>
				   	</form>
				</div>
				<!-- Block that contains the Continue as Guest button -->
			   	<div class="submit-button-block">
				   	<form action="index.jsp" method="get">
				   		<input type="submit" value="Continue as Guest">
				   	</form>
			   	</div>
	       <% }
	        // Closes the connection to the database
	        conn.close();
		// If error is found when connecting to the mySQL database
	    } catch (SQLException e) {
				e.printStackTrace();
				out.println("Connection failed: " + e.getMessage());
		}
    } else {%>
    	<!-- Block that contains the Register title, label and text fields for username, email, password, and 
		 confirm password, as well as the Register button -->
		<div class="main-block">
			<!-- Form that submits to this page, passing the user inputs from the text fields -->
			<form id="registerForm" class="register-form" action="register.jsp" method="POST">
				<!-- Nested block, contains the Register title and Registration failed message -->
			   	<div class="login-title-block">
			   		<h1>Register</h1>
			   		<p><%=validationResults %></p>
			   	</div>
			   	<!-- Nested Block, contains the username label and text field -->
			   	<div class="username-field-block">
			   		<span class="username-field-label">Username:</span>
			   		<input type="text" class="input-field" name="username">
			   	</div>
			   	<!-- Nested Block, contains the email label and text field -->
			   	<div class="email-field-block">
			   		<span class="email-field-label">Email:</span>
			   		<input type="text" class="input-field" name="email">
			   	</div>
			   	<!-- Nested Block, contains the password label and text field -->
			   	<div class="password-field-block">
			   		<span class="password-field-label">Password:</span>
			   		<input type="password" class="input-field" name="password">
			   	</div>
			   	<!-- Nested Block, contains the confirm password label and text field -->
			   	<div class="confirm-password-field-block">
			   		<span class="confirm-password-field-label">Confirm Password:</span>
			   		<input type="password" class="input-field" name="confirm-password">
			   	</div>
			   	<!-- Nested Block, contains the Register submit button -->
			   	<div class="submit-button-block">
			   		<input type="submit" value="Register">
			   	</div>
		   	</form>
		</div>
		<!-- Block that contains the Continue as Guest button -->
	   	<div class="submit-button-block">
		   	<form action="index.jsp" method="get">
		   		<input type="submit" value="Continue as Guest">
		   	</form>
	   	</div>
    <%}
    
 // If the register.jsp page was loaded from a different page, form was not submitted via "POST"
} else {%>
	<!-- Block that contains the Register title, label and text fields for username, email, password, and 
		 confirm password, as well as the Register button -->
	<div class="main-block">
		<!-- Form that submits to this page, passing the user inputs from the text fields -->
		<form id="registerForm" class="register-form" action="register.jsp" method="POST">
			<!-- Nested block, contains the Register title and Registration failed message -->
		   	<div class="login-title-block">
		   		<h1>Register</h1>
		   	</div>
		   	<!-- Nested Block, contains the username label and text field -->
		   	<div class="username-field-block">
		   		<span class="username-field-label">Username:</span>
		   		<input type="text" class="input-field" name="username">
		   	</div>
		   	<!-- Nested Block, contains the email label and text field -->
		   	<div class="email-field-block">
		   		<span class="email-field-label">Email:</span>
		   		<input type="text" class="input-field" name="email">
		   	</div>
		   	<!-- Nested Block, contains the password label and text field -->
		   	<div class="password-field-block">
		   		<span class="password-field-label">Password:</span>
		   		<input type="password" class="input-field" name="password">
		   	</div>
		   	<!-- Nested Block, contains the confirm password label and text field -->
		   	<div class="confirm-password-field-block">
		   		<span class="confirm-password-field-label">Confirm Password:</span>
		   		<input type="password" class="input-field" name="confirm-password">
		   	</div>
		   	<!-- Nested Block, contains the Register submit button -->
		   	<div class="submit-button-block">
		   		<input type="submit" value="Register">
		   	</div>
	   	</form>
	</div>
	<!-- Block that contains the Continue as Guest button -->
   	<div class="submit-button-block">
	   	<form action="index.jsp" method="get">
	   		<input type="submit" value="Continue as Guest">
	   	</form>
   	</div>
<%} %>
</body>
</html>