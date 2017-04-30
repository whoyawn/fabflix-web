<%@page import="java.sql.*,
                javax.sql.*,
                java.io.IOException"
%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="movies.Movie" %>
<%@ page import="movies.Constants" %>
<%@ page import="movies.Star" %>
<%

    //Get session attributes
    String customerId = (String) session.getAttribute("customerId");
    String customerFirstName = (String) session.getAttribute("customerFirstName");
    String customerLastName = (String) session.getAttribute("customerLastName");
    String loggedIn = (String) session.getAttribute("loggedIn");

    //Check to see if the user has logged in. If not, redirect user to the login page.
    if (loggedIn == null) {
        out.println("<script> window.location.replace('index.html'); </script>");
    }

    //Get total movie quantity in shopping cart
    int totalQuantity = 0;
    ArrayList<Movie> shoppingCart = new ArrayList<Movie>();
    if (session.getAttribute("shoppingCart") != null){
        shoppingCart = (ArrayList<Movie>)session.getAttribute("shoppingCart");
        for (int i = 0; i < shoppingCart.size(); i++){
            totalQuantity += Integer.parseInt(shoppingCart.get(i).quantity);
        }
    }

%>
<%
    Class.forName("com.mysql.jdbc.Driver").newInstance();

    String loginUser = Constants.USER;
    String loginPasswd = Constants.PASSWORD;
    String loginUrl = "jdbc:mysql:///moviedb?autoReconnect=true&useSSL=false";

    Connection dbcon = DriverManager.getConnection(loginUrl, loginUser, loginPasswd);

    response.setContentType("text/html");

    Statement statement = dbcon.createStatement();

    String starID = request.getParameter("id");

    String query = String.format("select CONCAT(first_name, \" \", last_name) as full_name, id, photo_url, dob from stars where id = %s;", starID);

    ResultSet rs = statement.executeQuery(query);

    PreparedStatement movieStatement;
    String movieQuery = "SELECT banner_url, title, id from movies WHERE id in (select movie_id FROM stars_in_movies WHERE star_id = ?);";
    movieStatement = dbcon.prepareStatement(movieQuery);

    Star star = new Star();

    while (rs.next()) {

        //Get movie information
        String resultId = rs.getString("id");
        String resultName = rs.getString("full_name");
        String resultPhotoURL = rs.getString("photo_url");
        String resultDOB = rs.getString("dob");

        star.id = resultId;
        star.name = resultName;
        star.photoURL = resultPhotoURL;
        star.dob = resultDOB;

        movieStatement.setString(1, resultId);
        ResultSet movieResultSet = movieStatement.executeQuery();
        while (movieResultSet.next()){
            String resultMovieTitle = movieResultSet.getString("title");
            String resultMovieID = movieResultSet.getString("id");
            String resultBannerURL = movieResultSet.getString("banner_url");
            Movie movie = new Movie(resultMovieID, resultMovieTitle);
            movie.bannerURL = resultBannerURL;
            star.movies.add(movie);
        }

        movieResultSet.close();
    }

    //Close prepared statements
    movieStatement.close();
%>
<!DOCTYPE html>
<html>
<head>
    <%--<link rel="stylesheet" type="text/css" href="https://myanimelist.cdn-dena.com/static/assets/css/pc/style-cfe6975aa5.css">--%>
        <link rel="stylesheet" type="text/css" href="css/mal.css">
</head>

<body onload=" " class="page-common" data-pin-hover="true">
<div id="myanimelist">


    <script type="text/javascript">
        window.MAL.SkinAd.prepareForSkin('skin_detail');
    </script>

    <div id="ad-skin-bg-left" class="ad-skin-side-outer ad-skin-side-bg bg-left">
        <div id="ad-skin-left" class="ad-skin-side left" style="display: none;">
            <div id="ad-skin-left-absolute-block">
                <div id="ad-skin-left-fixed-block"></div>
            </div>
        </div>
    </div>
    <div class="wrapper">
        <div id="headerSmall" style="background: url(../resources/logo_small.png) center top no-repeat rgba(0, 0, 0, 0)">
            <a href="/" class="link-mal-logo">Fabflix</a>
        </div>
        <div id="menu" class="">
            <div id="menu_left">
                <ul id="nav">
                    <li class="small">
                        <%--Must be ../ because the current path is servlet/--%>
                        <a href="../search.jsp" class="non-link">Search</a>
                    </li>
                    <li class="small">
                        <a href="../browse.jsp" class="non-link">Browse</a>
                    </li>
                    <%
                        if (totalQuantity < 10){
                            out.println("<li class=\"large\" style = 'width:160px;'>");
                        } else if (totalQuantity < 100){
                            out.println("<li class=\"large\" style = 'width:170px;'>");
                        } else if (totalQuantity < 1000){
                            out.println("<li class=\"large\" style = 'width:180px;'>");
                        } else if (totalQuantity < 10000){
                            out.println("<li class=\"large\" style = 'width:190px;'>");
                        } else {
                            out.println("<li class=\"large\" style = 'width:200px;'>");
                        }
                    %>
                    <a href="../shoppingCart.jsp" class="non-link">Checkout (<% out.println(totalQuantity); %> items) </a>
                    </li>
                    <li class="small">
                        <a href="/servlet/Logout" class="non-link">Logout</a>
                    </li>
                </ul>
            </div>
        </div>
        <div id="contentWrapper" itemscope="" itemtype="http://schema.org/Product">
            <div><h1 class="h1"><span itemprop="name"><% out.println(star.name); %></span></h1></div>
            <div id="content">

                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                    <tr>
                        <td class="borderClass" width="225" style="border-width: 0 1px 0 0;" valign="top">
                            <div class="js-scrollfix-bottom" style="width: 225px; position: static">
                                <div style="text-align: center;">
                                    <a href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2/pics">
                                        <img width="225" height="321" src="<% out.println(star.photoURL); %>" alt="Shingeki no Kyojin Season 2" class="ac" itemprop="image">
                                    </a>
                                </div>
                                <h2>Information</h2>
                                <div>
                                    <span class="dark_text">Given name:</span>
                                    <% out.println(star.name); %>
                                </div>
                                <div class="spaceit">
                                    <span class="dark_text">Birthday:</span>
                                    <% out.println(star.dob); %>
                                </div>
                            </div>
                        </td>
                        <td valign="top" style="padding-left: 5px;">
                            <div class="js-scrollfix-bottom-rel"><a name="lower"></a>
                                <div id="horiznav_nav" style="margin: 5px 0 10px 0;">
                                    <ul><li>
                                        <a href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2" class="horiznav_active">Details</a>
                                    </li></ul>
                                </div>


                                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                    <tbody>
                                    <tr>
                                        <td valign="top">
                                            <div class="pb16">
                                                <div class="di-t w100 mt12">
                                                    <div class="anime-detail-header-video di-tc va-t pl16" style="width:200px;">
                                                    </div>
                                                </div>
                                                <div class="js-myinfo-error badresult-text al pb4"
                                                     style="display:none;"></div>
                                            </div>
                                            <h2>
                                                <div class="floatRightHeader"><a
                                                        href="/dbchanges.php?aid=25777&amp;t=synopsis"
                                                        style="font-weight: normal;">Edit</a></div>
                                                Synopsis
                                            </h2>
                                            <span itemprop="description">Second season of <i>Shingeki no Kyojin</i>.</span>
                                            <h2 style="margin-top: 15px;">
                                                <div class="floatRightHeader"><a
                                                        href="/dbchanges.php?aid=25777&amp;t=background"
                                                        style="font-weight: normal;">Edit</a></div>
                                                Background
                                            </h2>
                                            No background information has been added to this title. Help improve our
                                            database by adding background information <a
                                                href="/dbchanges.php?aid=25777&amp;t=background">here</a>.<br>
                                            <h2 style="margin-top: 15px;">
                                                <div class="floatRightHeader"><a
                                                        href="/anime/25777/Shingeki_no_Kyojin_Season_2/video">More
                                                    Videos</a></div>
                                                Episode Videos
                                            </h2>
                                            <div class="anime-slide-block" id="episode_video"
                                                 data-json="{&quot;width&quot;:800,&quot;btnWidth&quot;:40,&quot;margin&quot;:8}"
                                                 style="height: 129px; width: 800px;">
                                                <div class="btn-anime-slide-side left"
                                                     style="display: none; left: -40px; opacity: 0;"><span
                                                        class="btn-inner"></span></div>
                                                <div class="btn-anime-slide-side right"
                                                     style="display: none; right: -40px; opacity: 0;"><span
                                                        class="btn-inner"></span></div>
                                                <div class="anime-slide-outer" style="width: 800px;">
                                                    <ul class="anime-slide js-anime-slide" data-slide="4"
                                                        style="width: 1616px;">
                                                        <li class="btn-anime" style="width:194px;"><a
                                                                href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2/episode/4"
                                                                class="link"
                                                                style="background-image:url('http://img1.ak.crunchyroll.com/i/spire3-tmb/f8d8aaa0b6ea95fed54df3fec580093e1492833825_large.jpg');width:194px;height:129px;"><span
                                                                class="title pb8" style="width:184px;">
            Episode 4<span class="icon-pay ml4"></span></span></a></li>
                                                        <li class="btn-anime" style="width:194px;"><a
                                                                href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2/episode/3"
                                                                class="link"
                                                                style="background-image:url('http://img1.ak.crunchyroll.com/i/spire4-tmb/86d0daa9fb45aecdaabac03d2c544d011492213811_large.jpg');width:194px;height:129px;"><span
                                                                class="title pb8" style="width:184px;">
            Episode 3<span class=" ml4"></span></span></a></li>
                                                        <li class="btn-anime" style="width:194px;"><a
                                                                href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2/episode/2"
                                                                class="link"
                                                                style="background-image:url('http://img1.ak.crunchyroll.com/i/spire3-tmb/d1171eef18af9f480b54bb7384c5aa851491617802_large.jpg');width:194px;height:129px;"><span
                                                                class="title pb8" style="width:184px;">
            Episode 2<span class=" ml4"></span></span></a></li>
                                                        <li class="btn-anime" style="width:194px;"><a
                                                                href="https://myanimelist.net/anime/25777/Shingeki_no_Kyojin_Season_2/episode/1"
                                                                class="link"
                                                                style="background-image:url('http://img1.ak.crunchyroll.com/i/spire3-tmb/e722d61c2b44397d4c0983c975f790921491006928_large.jpg');width:194px;height:129px;"><span
                                                                class="title pb8" style="width:184px;">
            Episode 1<span class=" ml4"></span></span></a></li>
                                                    </ul>
                                                </div>
                                            </div>
                                            <div class="border_top"
                                                 style="padding:16px 0px 0px 0px;margin:14px 0px 0px 0px;"></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="pb24"><br><br>
                                            <h2>
                                                <div class="floatRightHeader"></div>
                                                Characters &amp; Voice Actors
                                            </h2>
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td valign="top" width="27" class="borderClass bgColor2" align="center"><div class="picSurround">
                                                <a href="/character/40881/Mikasa_Ackerman" style="font-weight: normal;">
                                                    <img src="https://myanimelist.cdn-dena.com/r/46x64/images/characters/9/215563.webp?s=a12e4bc7a7cf9b18f23b8d9d589a2268" width="23" height="32" alt="Ackerman, Mikasa" vspace="4" hspace="8" border="0">
                                                </a></div></td><td valign="top" class="borderClass bgColor2">
                                                <a href="/character/40881/Mikasa_Ackerman">Ackerman, Mikasa</a>
                                            </td></tr></tbody></table>
                                            <%
                                                for (Movie movie: star.movies) {
                                                    out.println("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tbody><tr><td valign=\"top\" width=\"27\" class=\"borderClass bgColor2\" align=\"center\"><div class=\"picSurround\">");
                                                    out.println("<a href=\"movie.jsp?id=" + movie.id + "\"" + "style=\"font-weight: normal;\">");
                                                    out.println("<img src=\"" + movie.bannerURL + "\"" + "width=\"23\" height=\"32\" alt=\"Ackerman, Mikasa\" vspace=\"4\" hspace=\"8\" border=\"0\">");
                                                    out.println("</a></div></td><td valign=\"top\" class=\"borderClass bgColor2\">");
                                                    out.println("<a href=\"movie.jsp?id=" + movie.id + "\">" + movie.title + "</a>");
                                                    out.println("</td></tr></tbody></table>");
                                                }
                                            %>


                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>

                        </td>
                    </tr>
                    </tbody>
                </table>
            </div><!-- end of contentHome -->
        </div><!-- end of contentWrapper -->


        <!--  control container height -->
        <div style="clear:both;"></div>

        <!-- end rightbody -->

    </div><!-- wrapper -->


    <div id="ad-skin-bg-right" class="ad-skin-side-outer ad-skin-side-bg bg-right">
        <div id="ad-skin-right" class="ad-skin-side right" style="display: none;">
            <div id="ad-skin-right-absolute-block">
                <div id="ad-skin-right-fixed-block"></div>
            </div>
        </div>
    </div>
</div><!-- #myanimelist -->


<div id="evolve_footer"></div>

<script type="text/javascript">
    window.MAL.magia = "06410c4e6b2518e9add8f6df0ccb2da2876bb8c980aacb43a8dcaa8153c0f92c";
    window.MAL.madoka = "hZrDKm9k6FVRnqd3i%=K";

    window.MAL.SLVK = "g4OvMLVOmEI3J8u7dt8f8+mAuualsqCo";
    window.MAL.CDN_URL = "https://myanimelist.cdn-dena.com";

    window.MAL.CURRENT_TUTORIAL_STEP_ID = null;
    window.MAL.USER_NAME = "blankpaper"
</script>


<div id="fancybox-tmp" style="padding: 70px;"></div>
<div id="fancybox-loading" style="display: none;">
    <div></div>
</div>
<div id="fancybox-overlay" style="background-color: rgb(102, 102, 102); opacity: 0.3; display: none;"></div>
<div id="fancybox-wrap"
     style="opacity: 1; width: 1172.8px; height: 673.6px; top: 89.2px; left: 151.6px; display: none;">
    <div id="fancybox-outer">
        <div class="fancy-bg" id="fancy-bg-n"></div>
        <div class="fancy-bg" id="fancy-bg-ne"></div>
        <div class="fancy-bg" id="fancy-bg-e"></div>
        <div class="fancy-bg" id="fancy-bg-se"></div>
        <div class="fancy-bg" id="fancy-bg-s"></div>
        <div class="fancy-bg" id="fancy-bg-sw"></div>
        <div class="fancy-bg" id="fancy-bg-w"></div>
        <div class="fancy-bg" id="fancy-bg-nw"></div>
        <div id="fancybox-inner" style="top: 0px; left: 0px; width: 1172.8px; height: 673.6px; overflow: hidden;"></div>
        <a id="fancybox-close" style="display: none;"></a><a href="javascript:;" id="fancybox-left"
                                                             style="display: none;"><span class="fancy-ico"
                                                                                          id="fancybox-left-ico"></span></a><a
            href="javascript:;" id="fancybox-right" style="display: none;"><span class="fancy-ico"
                                                                                 id="fancybox-right-ico"></span></a>
    </div>
</div>
<div id="fb-root" class=" fb_reset">
    <div style="position: absolute; top: -10000px; height: 0px; width: 0px;">
        <div></div>
    </div>
    <div style="position: absolute; top: -10000px; height: 0px; width: 0px;">
        <div>
            <iframe name="fb_xdm_frame_https" frameborder="0" allowtransparency="true" allowfullscreen="true"
                    scrolling="no" id="fb_xdm_frame_https" aria-hidden="true"
                    title="Facebook Cross Domain Communication Frame" tabindex="-1"
                    src="https://staticxx.facebook.com/connect/xd_arbiter/r/87XNE1PC38r.js?version=42#channel=f98bce420245c8&amp;origin=https%3A%2F%2Fmyanimelist.net"
                    style="border: none;"></iframe>
        </div>
    </div>
</div>
</body>
</html>