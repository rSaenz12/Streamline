<%
/*
 * Program name: Project - Streamline
 *
 * File Name: search.jsp
 * 
 * Developer: Lucas Brown, Russel Saenz, Kane Villareal, Chase Dennis, Carlos Glover, Trey Harrison
 * 
 * Date Created: 9/29/2024
 * 
 * Version: 5.0
 * 
 * Purpose: Displays the search results page. This includes a header made up of a search bar that links to the same page to change the search input and two drop-down menus for
 *		 	sorting and filtering of the search results. The page also includes the list of search results, which shows the data from the database for each movie/game that was
 *			found using the search query built from the user search input.
 *			If the user is logged into their account, each search result will display a button to add the movie/game to their watched/played list.
 *			If the user is not logged into their account, each search result will display the text "Login or Register to add this movie/game to your list" that links to register.jsp
 *
 * Note: Code/Comments use the word "media" to refer to the movie/game it is effecting.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Streamline - Search Results</title>
<link rel="stylesheet" type="text/css" href="styles/global.css"/>
<link rel="stylesheet" type="text/css" href="styles/search.css"/>
<script >
	// This function sets the selected movie name in the hidden input field and submits the form
	function selectMedia(mediaName, mediaType, searchInput, sort, type) {
		 // Set the selected media name in the hidden input field
	    document.getElementById('mediaName').value = mediaName;
	    document.getElementById('mediaType').value = mediaType;
	    // sets the values for the search input, selected sort, and selected type to restore them after returning from the success page
	    document.getElementById('searchInput').value = searchInput;
	    document.getElementById('sortValue').value = sort;
	    document.getElementById('typeValue').value = type; 
	    document.getElementById('submitForm').submit();  // Submit the form after selection
	}
</script>
</head>
<body class="body">

	<%
		// Attributes needed to operate sql
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("MMMM d, yyyy");
	
		// Gets the parameters from the submitted form
		String searchInput = request.getParameter("searchInput").toString();
		String sort = request.getParameter("sort").toString();
		String type = request.getParameter("type").toString();
	%>

<!-- Form that is used to send the needed parameters to insertSeenMedia.jsp when an "Add to List" button is clicked -->
<form id="submitForm" action="insertSeenMedia.jsp" method="post" style="display:none;">
		<!-- Contains the name of the media being added to the users watched/played list -->
		<input type="hidden" name="mediaName" id="mediaName">
		<!-- Contains if the media is a movie or game -->
		<input type="hidden" name="mediaType" id="mediaType">
		<!-- Contains the input that the user entered into the search bar to restore it when the user returns to this page-->
	    <input type="hidden" name="searchInput" id="searchInput">
	    <!-- Contains the selected value of the sort drop-down menu to restore it when the user returns to this page -->
	    <input type="hidden" name="sortValue" id="sortValue">
	    <!-- Contains the selected value of the filter drop-down menu to restore it when the user returns to this page -->
	    <input type="hidden" name="typeValue" id="typeValue">
	    <!-- Contains the name of this page for proper attribute handling for insertSeenMedia.jsp -->
	    <input type="hidden" name="sourcePage" id="sourcePage" value="search">
	    <!-- Contains the ID of the users account -->
	    <input type="hidden" name="userID" value="<%= session.getAttribute("userId") %>"> 
</form>
	<!-- Block that contains the Return to Homepage button -->
	<div class="return-to-homepage-block">
		<form action="index.jsp" method="get">
			<input type="submit" value="Return to Homepage">
		</form>
	</div>
	<h1>Search Results</h1>
	<!-- Block that contains the search bar and its related submit button, the sort drop-down menu, and the filter drop-down menu  -->
	<div class="header-block">
		<!-- Form that submits to this same page -->
		<form name="search-form" action="search.jsp" method="get">
			<!-- Nested Block, contains the search bar and its related submit button -->
			<div class="search-input-block">
				<input type="text" name="searchInput" class="search-bar" placeholder="Search"
					value="<%=searchInput != null ? searchInput : ""%>">
				<input type="submit" class="search-button" value="Search">
			</div>
			<!-- Nested Block, contains the sort and filter drop-down menus -->
			<div class="sort-and-type-block">
				<!-- Sort drop-down menu -->
				<select name="sort" class="sort-menu" onchange="this.form.submit()">
					<option value="relevance"
						<%="relevance".equals(sort) ? "selected" : ""%>>Relevance</option>
					<option value="dateDescending"
						<%="dateDescending".equals(sort) ? "selected" : ""%>>Release
						Date (Descending)</option>
					<option value="dateAscending"
						<%="dateAscending".equals(sort) ? "selected" : ""%>>Release
						Date (Ascending)</option>
					<option value="alphabet"
						<%="alphabet".equals(sort) ? "selected" : ""%>>Alphabetical</option>
				</select>
				<!-- Filter drop-down menu -->
				<select name="type" class="type-menu" onchange="this.form.submit()">
					<option value="">Both Movies and Games</option>
					<option value="movie"
						<%="movie".equals(type) ? "selected" : ""%>>Movies</option>
					<option value="game"
						<%="game".equals(type) ? "selected" : ""%>>Games</option>
				</select>
			</div>
		</form>
	</div>
	<!-- Block that contains all the search results -->
	<div class="results-block">
		<%
		try {
			// Connects to database
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection(/*DB Key*/);
			// Creates SQL statement
			stmt = con.createStatement();

			// SQL query that receives the search results
			String query = "SELECT * FROM media WHERE name LIKE '%" + searchInput + "%' AND type LIKE '%" + type + "%'";
			
			// Adds the type of sorting from the sort drop-down menu to the end of the search query string, is by Relevance by default
			if("dateDescending".equals(sort)){
				query += " ORDER BY date DESC";
			} else if ("dateAscending".equals(sort)) {
				query += " ORDER BY date ASC";
			} else if ("alphabet".equals(sort)){
				query += " ORDER BY name ASC";
			}
			// Executes the query
			rs = stmt.executeQuery(query);
			
			// For every result received from the database
			while(rs.next()){
				/*
				 * Structure of each row from the database:
				 * {ID, Name, Release Date, Platform, Type, Genres, Similar titles, Description, Image Link}
				*/
				// Gets the type of the media, movie/game
				String mediaType = rs.getString(5);
				// Formats the release date to be "{month name} {month day}, {full year}"
				String formattedDate = dateFormatter.format(rs.getDate(3));%>
				<!-- Nested Block, One for each search result, Contains the media image, title, release date, genres, platforms, and "Add to List" button or
					"Login or Register" link -->
				<div class="media-block">
					<!-- Nested Block, Contains the media image -->
					<div class="media-poster-block">
						<img class="media-poster" src="<%= rs.getString(9) %>">
					</div>
					<!-- Nested Block, Contains the media title and release date -->
					<div class="column-block">
						<!-- Nested Block, Contains the media title -->
						<div class="top-row-block">
							<div class="title-block">
								<%String title = rs.getString(2); 
								  // Makes sure the title only displays as much characters that will fit in the block
								  if(title.length() > 43){
									  title = title.substring(0, 43) + "...";
								  }
								%>
								<span class="media-parameter-label"><%=mediaType.substring(0,1).toUpperCase()+mediaType.substring(1)%></span><br>
								<span class="media-parameter-value"><%=title%></span>
							</div>
						</div>
						<!-- Nested Block, Contains the media release date -->
						<div class="bottom-row-block">
							<div class="genre-block">
								<span class="media-parameter-label">Release Date</span><br>
								<span class="media-parameter-value"><%= formattedDate %></span>
							</div>
						</div>
					</div>
					<!-- Nested Block, contains the media genres and platforms where the media is available -->
					<div class="column-block">
						<!-- Nested Block, contains the media genres -->
						<div class="top-row-block">
							<div class="genre-block">
								<span class="media-parameter-label">Genres</span><br>
								<span class="media-parameter-value">
								<!-- Takes the string that contains the genres and converts it into a String array split by the ";" character -->
								<% String[] genres = rs.getString(6).split(";");
								for(int i = 0; i < genres.length && i < 5; i++){
									if(i != genres.length-1){ %>
									<%= genres[i] + ", " %>
									<% } else {%>
									<%= genres[i] %>
									<% } 
								 }
								if(genres.length > 5){%>
									<%= "..." %>
							 <% } %>
								</span>
							</div>
						</div>
						<!-- Nested Block, contains the platforms where the media is available -->
						<div class="bottom-row-block">
							<div class="platform-block">
								<span class="media-parameter-label">Platforms</span><br>
								<span class="media-parameter-value">
								<% String[] platforms = rs.getString(4).split(";");
								for(int i = 0; i < platforms.length && i < 5; i++){
									if(i != platforms.length-1){ %>
									<%= platforms[i] + ", " %>
									<% } else {%>
									<%= platforms[i] %>
									<% } 
								 }
								if(platforms.length > 5){%>
									<%= "..." %>
							 <% } %>
								</span>
							</div>
						</div>
					</div>
					<!-- Nested Block, contains the "Add to List" button or "Login or Register" link -->
					<div class="column-block">
						<div class="double-row-block">
							<!-- If the user is logged in to their account -->
							<% if(session.getAttribute("userId") != null) { %>
								<div class="media-parameter-label"><%
									if(mediaType.equals("movie")){%>
										<%="Already watched it?"%>
									<%} else if(mediaType.equals("game")){%>
										<%="Already played it?"%>
									<%}%>
								</div><br>
								<div class="media-parameter-value">
									<% out.println("<input type='submit' class='watched-list-button' value='Add to list' onclick='selectMedia(\""
									+ rs.getString(2) + "\",\"" + mediaType + "\",\"" + searchInput + "\",\"" + sort + "\",\"" + type + "\",)'>"); %>
								</div>
							<!-- If the user is not logged in to their account -->
							<%} else {%>
								<div class="media-parameter-label"><%
										if(mediaType.equals("Movie")){%>
											<%="Already watched it?"%>
										<%} else if(mediaType.equals("game")){%>
											<%="Already played it?"%>
										<%}%>
								</div><br>
								<a class="media-parameter-value" href="register.jsp"><%= "Login or register to add this " + mediaType + " to your list" %></a>
							<%} %>
						</div>
					</div>
				</div>
		<%}
		//Connection faling, will give message
		}catch (SQLException e) {
			e.printStackTrace();
			out.println("Connection failed: " + e.getMessage());
		}
		//If the JDBC (JAVA DATABASE CONNECTION, SEE LINE 119 and 121) isnt found, it will put out a message
		catch (ClassNotFoundException e) {
			e.printStackTrace();
			out.println("JDBC Driver not found: " + e.getMessage());
		}

		finally {
			//This if statement will end the connection, if the connection was made
			if (con != null) {
				try {
			//This ends the connection specifically
			con.close();

				} catch (SQLException e) {
			e.printStackTrace();
				}
			}
		}
			%>
	</div>
</body>
</html>