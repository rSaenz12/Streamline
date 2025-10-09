<%
/*
 * Program name: Project - Streamline
 *
 * File Name: insertSeenMedia.jsp
 * 
 * Developer: Lucas Brown, Russel Saenz, Kane Villareal, Chase Dennis, Carlos Glover, Trey Harrison
 * 
 * Date Created: 9/29/2024
 * 
 * Version: 5.0
 * 
 * Purpose: Attempts to add the selected media from search.jsp or recommend.jsp into the users watched/played list in the database. 
 *			Displays a success message if the media was successfully added to the list, or an error message if it failed.
 *
 * Note: Code/Comments use the word "media" to refer to the movie/game it is effecting.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="styles/global.css"/>
    <style>
    	input[type=submit]{
			background-color: var(--primary-color);
			font-family:kg-miss-kindy;
			font-size: 18px;
			border-radius: var(--button-radius);
			border: none;
			padding: 5px 10px;
		}
		
		input[type=submit]:hover{
			background-color: var(--hover-color);
		}
		
		.body{
			background-color: var(--background-color);
		}
		
		h1 {
			font-family: kg-miss-kindy;
			font-size: 18px;
			color: var(--secondary-color);
			margin-left: 10px;
			white-space: nowrap;
		}
    </style>
    <title>Media Added</title>

</head>
<body class="body">

<%
    // Get parameters from the form
    String userID = request.getParameter("userID").toString();
    String mediaName = request.getParameter("mediaName");
    String mediaType = request.getParameter("mediaType");
    String sourcePage = request.getParameter("sourcePage");
    String[] genreNames = {"Drama", "Crime", "Action", "Fantasy", "Sci-Fi", "Horror", "Comedy", "Mystery", "Personalized"};
   	String searchInput = request.getParameter("searchInput");
   	String sort = request.getParameter("sortValue");
   	String type = request.getParameter("typeValue");
    

    if (userID == null || userID.isEmpty() || mediaName == null || mediaName.isEmpty()) {
        out.println("Error: Missing userID or SearchName.");
        return;
    }

    Connection con = null;
    PreparedStatement stmt = null;
    
    Connection connection2 = null;
    Statement stmt2 = null;
	ResultSet rs = null;
	
    try {
    	
        // Load JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish connection to the database
        con = DriverManager.getConnection(/*DB Key*/);

        // Insert the selected movie into SeenMovies table
        String insertQuery = "INSERT INTO SeenMovies (UserId, SeenMovies, Type) VALUES (?, ?, ?)";
        stmt = con.prepareStatement(insertQuery);
        stmt.setInt(1, Integer.parseInt(userID));  // Assuming userID is an integer
        stmt.setString(2, mediaName);  // Set the movie name
        stmt.setString(3, mediaType);

        int rowsAffected = stmt.executeUpdate();
        if (rowsAffected > 0) {
            out.println("<h1>"+ mediaType.substring(0, 1).toUpperCase() + mediaType.substring(1) + " '" + mediaName + "' has been successfully added to your list.</h1>");
        } else {
            out.println("<h1>Error: Could not add the "+ mediaType +".</h1>");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h1>SQL Error: " + e.getMessage() + "</h1>");
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.println("<h1>JDBC Driver Error: " + e.getMessage() + "</h1>");
    } finally {
        // Clean up
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt2 != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (connection2 != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
    
%>

<!-- Hidden forms that send the parameters needed to restore the users settings for the previous page -->
<!-- If the previous page was search.jsp -->
<%if(sourcePage.equals("search")){ %>
	<form name = "Return to search" action = search.jsp method = "get">
		<!-- Contains the input that the user entered into the search bar -->
		<input type="hidden" name="searchInput" placeholder="Search" value="<%= searchInput %>">
		<!-- Contains the value that the sort drop-down menu was set to -->
		<input type="hidden" name="sort" value="<%= sort %>">
		<!-- Contains the value that the filter drop-down menu was set to -->
	    <input type="hidden" name="type" value="<%= type %>"> 
		<input type="submit" value = "Return">
	</form>
<!-- If the previous page was recommend.jsp -->
<%} else if(sourcePage.equals("recommend")){%>
	<form name = "Return to recommendations" action = recommend.jsp method = "get">
		<!-- Creates a hidden input that contains the previous status of each genre check-box -->
		<%for(String genre: genreNames){ 
			if(request.getParameter(genre) != null){%>
				<input type="hidden" name="<%=genre %>" value="<%=genre %>">
			<%}
		}%>
		<input type="submit" value = "Return">
	</form>
<%} %>
</body>
</html>