<%
/*
 * Program name: Project - Streamline
 *
 * File Name: recommend.jsp
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
 *			If the user is logged into their account, there will be an additional checkbox in the header labeled "Personalized" which determines if the recommendation results are
 *			currated based on your watched list, as well as each search result will display a button to add the movie/game to their watched/played list.
 *			If the user is not logged into their account, each search result will display the text "Login or Register to add this movie/game to your list" that links to register.jsp
 *
 * Note: Code/Comments use the word "media" to refer to the movie/game it is effecting.
 * 
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Recommendations</title>
<link rel="stylesheet" type="text/css" href="styles/global.css"/>
<link rel="stylesheet" type="text/css" href="styles/recommend.css"/>
<script >
	// This function sets the selected movie name in the hidden input field and submits the form
	function selectMedia(mediaName, mediaType, checkedGenres) {
		console.log("in selectMedia()");
		var checkedGenreArray = null;
		if(!checkedGenres == ""){
			checkedGenreArray = checkedGenres.split(";");
			 for(var i = 0; i < checkedGenreArray.length; i++){
		    	document.getElementById(checkedGenreArray[i]).value = checkedGenreArray[i];
		    }
		}
		 // Set the selected media name in the hidden input field
	    document.getElementById('mediaName').value = mediaName;
	    document.getElementById('mediaType').value = mediaType;
	    document.getElementById('submitForm').submit();  // Submit the form after selection
	}
</script>
</head>
<body class="body">
<%  
	// Object that formats the release date for display
	SimpleDateFormat dateFormatter = new SimpleDateFormat("MMMM d, yyyy");
%>
	<!-- Block that contains the Return to Homepage button -->
	<div class="return-to-homepage-block">
		<form action="index.jsp" method="get">
			<input type="submit" value="Return to Homepage">
		</form>
	</div>
	<h1>Recommendations</h1>					
	<%	
	String[] genreNames;
	// If user is logged in to their account
	if(session.getAttribute("userId") != null){
		genreNames = new String[9];
		genreNames[0] = "Drama";
		genreNames[1] = "Crime";
		genreNames[2] = "Action";
		genreNames[3] = "Fantasy";
		genreNames[4] = "Sci-Fi";
		genreNames[5] = "Horror";
		genreNames[6] = "Comedy";
		genreNames[7] = "Mystery";
		genreNames[8] = "Personalized";
	// If user is not logged in to their account
	} else {
		genreNames = new String[8];
		genreNames[0] = "Drama";
		genreNames[1] = "Crime";
		genreNames[2] = "Action";
		genreNames[3] = "Fantasy";
		genreNames[4] = "Sci-Fi";
		genreNames[5] = "Horror";
		genreNames[6] = "Comedy";
		genreNames[7] = "Mystery";
	} %>
	<!-- Block that holds the genre check-boxes -->
	<div class="genre-menu-block">
		<!-- Form that resubmits to this page if a check-box is selected or de-selected -->
		<form name= "genre-selection-form" action= "recommend.jsp" method= "post">
		<!-- Holds the status of the current check-box in the loop -->
		<% String checked = null; %>
		<!-- Creates a check-box for each genre in the genreNames array -->
		<% for(String genre: genreNames){ 
			// Gets the status of the current genre check-box, makes sure that the status of all check-boxes remains the same upon form resubmission
			checked = request.getParameter(genre);%>
			<div class="genre-selection-block">
				<label class="genre-custom-checkbox">
					<input type="checkbox" class="genre-checkbox" name=<%=genre%> id=<%=genre%> value=<%=genre%> onchange="this.form.submit()" 
					<% if(genre.equals(checked)){ out.print("checked=\"checked\""); } %>>
					<span class="checkmark"></span>
				</label>
				<label class="genre-label" for=<%=genre%>><%=genre%></label>
			</div>
		<% } %>
		</form>
	</div>
	<!-- Form that is used to send the needed parameters to insertSeenMedia.jsp when an "Add to List" button is clicked -->
	<form id="submitForm" action="insertSeenMedia.jsp" method="post" style="display:none;">
			<!-- Contains the name of the media being added to the users watched/played list -->
			<input type="hidden" name="mediaName" id="mediaName">
			<!-- Contains if the media is a movie or game -->
			<input type="hidden" name="mediaType" id="mediaType">
			<!-- Passes the status of each genre check-box -->
		    <% for(String genre: genreNames){
		    	if(request.getParameter(genre) != null){%>
		    		<input type="hidden" name="<%=genre%>" id="<%=genre%>">
		       <%} %>
		    <%}%>
		    <!-- Contains the name of this page for proper attribute handling for insertSeenMedia.jsp -->
		    <input type="hidden" name="sourcePage" value="recommend">
		    <!-- Contains the ID of the users account -->
		    <input type="hidden" name="userID" value="<%= session.getAttribute("userId") %>"> 
	</form>
	<!-- Block that contains all the recommendation results -->
	<div class="results-block">
	<%
	/* Initializes the list of genres that are placed into a string for restoring settings
	 when loading a new page and then returning to this one.*/
	String checkedGenres = "";
	for(String genre: genreNames){
		if(request.getParameter(genre) != null && request.getParameter(genre).equals(genre)){
			checkedGenres += genre + ";";
		}
	}
	// If no genre check-boxes are checked
	if(!checkedGenres.equals("")){
		checkedGenres = checkedGenres.substring(0, checkedGenres.length()-1);
	}
	
	// Attributes needed to operate sql
	Connection con = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	try {

		// Connects to the SQL database
		Class.forName("com.mysql.cj.jdbc.Driver");
		con = DriverManager.getConnection(/*DB Key*/);
		// Creates the SQL statement object
		stmt = con.createStatement();
		
		// SQL query that receives the search results
		String query = "SELECT * FROM media";
		
		boolean filterOn = false;
		for(String genre: genreNames){
			if(request.getParameter(genre) != null){
				if(!filterOn){
					filterOn = true;
					query += " WHERE";
				}
				query += " genre LIKE '%" + genre + "%' AND";
			}
			// If the current check-box being added to the query is the "Personalized" checkbox
			if( "Personalized".equals(request.getParameter(genre))){
				if(!filterOn){
					filterOn = true;
				}
				// Initializes attributes needed to retrieve the users list of seen media from the database
				String UserID = session.getAttribute("userId").toString();
				String queryFromSeenMovies = null;
				Statement getNameFromSeenMovies = null;					
				getNameFromSeenMovies = con.createStatement();
				ResultSet seenMoviesResult = null;

				// String query for retrieving the users seen media
				queryFromSeenMovies = "SELECT * FROM SeenMovies WHERE UserID ="+UserID;
				
				// Executes the query
				seenMoviesResult = getNameFromSeenMovies.executeQuery(queryFromSeenMovies);
					while(seenMoviesResult.next()){
						// Adds the title of each seen media to the query for the recommendation results
						String name = seenMoviesResult.getString("SeenMovies");
						query += " Similar LIKE '%" + name + "%' OR ";
					
					}
				
				
			}
		}
		// Removes the remaining "AND" from the end of the search query if any genre was added to the end of it
		if(filterOn){
			query = query.substring(0, query.length() - 4);
		}
		
		// Executing SQL query to the media database
		rs = stmt.executeQuery(query);
		
		// For each media received from the database for the recommendation results
		while(rs.next()) {
			String mediaType = rs.getString("Type");
			// Formats the release date of the current media in the loop
			String formattedDate = dateFormatter.format(rs.getDate("Date"));
			%>
			<!-- Nested Block, One for each search result, Contains the media image, title, release date, genres, platforms, and "Add to List" button or "Login or Register" link -->
			<div class="media-block">
				<!-- Nested Block, Contains the media image -->
				<div class="media-poster-block">
						<img class="media-poster" src="<%= rs.getString("Image") %>">
				</div>
				<!-- Nested Block, Contains the media title and release date -->
				<div class="column-block">
					<!-- Nested Block, Contains the media title -->
					<div class="top-row-block">
						<div class="title-block">
							<%String title = rs.getString("Name"); 
							  // Makes sure the title only displays as much characters that will fit in the block
							  if(title.length() > 45){
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
							<% String[] genres = rs.getString("Genre").split(";");
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
							<% String[] platforms = rs.getString("Services").split(";");
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
							<%	out.println("<input type='submit' class='watched-list-button' value='Add to list' onclick='selectMedia(\""
									+ rs.getString("Name") + "\",\"" + mediaType + "\",\"" + checkedGenres + "\")'>"); %>
							</div>
						<!-- If the user is not logged in to their account -->
						<%} else {%>
							<div class="media-parameter-label"><%
									if(mediaType.equals("movie")){%>
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
	//Catch for error handling. 
	} //Connection faling, will give message
	catch (SQLException e) {
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