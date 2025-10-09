<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%--NEEDED FOR SQL --%>
<%@ page import="java.sql.*"%>

<%@ page import="java.text.SimpleDateFormat"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Your list</title>
<link rel="stylesheet" type="text/css" href="styles/global.css" />
<link rel="stylesheet" type="text/css" href="styles/userList.css" />


  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Home Button</title>
  <link rel="stylesheet" href="styles.css">

</head>
<body class="body">
<div class="return-to-homepage-block">
		<form action="index.jsp" method="get">
			<input type="submit" value="Return to Homepage">
		</form>
</div>
<h1>Your List</h1>
<%-- Start of the block for the options --%>
<div class="type-menu-block">
    <form name="Game-Or-Movie" action="UserLists.jsp" method="get">
        <!-- Radio button for movie option -->
        <label class="genre-custom-checkbox">
            <input type="radio" name="type" value="movie" 
                <%= request.getParameter("type") != null && request.getParameter("type").equals("movie") ? "checked" : "" %> >
            <span class="checkmark"></span>Movie
        </label>

        <!-- Radio button for game option -->
        <label class="genre-custom-checkbox">
            <input type="radio" name="type" value="game" 
                <%= request.getParameter("type") != null && request.getParameter("type").equals("game") ? "checked" : "" %> >
            <span class="checkmark"></span>Game
        </label>

        <input type="submit" name="submit" value="Submit">
    </form>
</div>





	<%
	//needed variables to operate the sql querys
	String type = request.getParameter("type");
	String UserID = session.getAttribute("userId").toString();
	
	Connection con = null;
	
	//needed statments
	Statement stmt = null;
	Statement FromMediaTable= null;
	//needed Result sets
	ResultSet rs =null;
	ResultSet seenQuery = null;
	
	try{
		
		//formats the date
		SimpleDateFormat dateFormatter = new SimpleDateFormat("MMMM d, yyyy");
		//API
		Class.forName("com.mysql.cj.jdbc.Driver");
		//Connection
		con = DriverManager.getConnection(/*DB Key*/);
		//creating sql statement
		stmt = con.createStatement();
		FromMediaTable=  con.createStatement();
			//query to get the seen media names from the SeenMovies table
		String querySeen = "SELECT * FROM SeenMovies WHERE UserID ="+UserID+" AND Type = '"+type+"';";
		
			//execute query statement
		seenQuery= stmt.executeQuery(querySeen);
			//creating string for the data that will be pulled from the media table
		String query = "SELECT * FROM media WHERE ";
		
		boolean listIsEmpty = true;
			//initiate query, gets name, then adds to the second query
		while(seenQuery.next()){
			listIsEmpty = false;
				//name is the medias name from the seen table
			String name = seenQuery.getString("SeenMovies");
				//sets condition of name must = name to be pulled
			query += "name = '"+name+"' OR ";
		}
		
			//removes the leftover " OR "
		query = query.substring(0, query.length() - 4);
		
			//executes the query
		rs=FromMediaTable.executeQuery(query);
		if(!listIsEmpty){
		while(rs.next()) {
			
			String mediaType = rs.getString("Type");
			//formats date from sql date to readable dates
			String formattedDate = dateFormatter.format(rs.getDate("Date"));
			%>
			<div class="media-block">
					<%-- block that will display poster image --%>
				<div class="media-poster-block">
						<%--Uses poster link --%>
					<img class="media-poster" src="<%= rs.getString("Image") %>">
				</div>
				<div class="column-block">
					<div class="top-row-block">
							<%--displays title --%>
						<div class="title-block">
							<%
								//ensures that the title isnt too long and doesnt interfer with format
								String title = rs.getString("Name"); 
							  if(title.length() > 45){
								  title = title.substring(0, 43) + "...";
							  }
							%>
							<span class="media-parameter-label"><%=mediaType.substring(0,1).toUpperCase()+mediaType.substring(1)%></span><br>
							<span class="media-parameter-value"><%=title%></span>
						</div>
					</div>
					<div class="bottom-row-block">
						<div class="genre-block">
							<%-- displays formatted date --%>
							<span class="media-parameter-label">Release Date</span><br> <span
								class="media-parameter-value"><%= formattedDate %></span>
						</div>
					</div>
				</div>
				<div class="column-block">
					<div class="top-row-block">
						<div class="genre-block">
							<span class="media-parameter-label">Genres</span><br> <span
								class="media-parameter-value"> <%
									//splits up genres and displays them in nice list, genres stored in genre;genre;genre originally
								String[] genres = rs.getString("Genre").split(";");
								for(int i = 0; i < genres.length && i < 5; i++){
									if(i != genres.length-1){ %> <%= genres[i] + ", " %> <% } else {%>
								<%= genres[i] %> <% } 
								 }
								if(genres.length > 5){%> <%= "..." %> <% } %>
							</span>
						</div>
					</div>
					<div class="bottom-row-block">
						<div class="platform-block">
							<span class="media-parameter-label">Platforms</span><br> <span
								class="media-parameter-value"> <%
									//splits up platforms, they are stored the same way as genre
								String[] platforms = rs.getString("Services").split(";");
								for(int i = 0; i < platforms.length && i < 5; i++){
									if(i != platforms.length-1){ %> <%= platforms[i] + ", " %> <% } else {%>
								<%= platforms[i] %> <% } 
								 }
								if(platforms.length > 5){%> <%= "..." %> <% } %>
							</span>
						</div>
					</div>
				</div>
				<div class="column-block">
					<div class="double-row-block"></div>
					<br>
				</div>
			</div>
		
		<%}
		}
	}
		//EXCEPTION HANDLING
		//these will trigger if any problem with reaching the sql DB is encountered
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


</body>
</html>
