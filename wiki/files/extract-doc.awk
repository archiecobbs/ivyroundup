# $Id$

BEGIN {
  printf ("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n");
  printf ("<html>\n");
  printf ("<head>\n");
  printf ("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">\n");

  printf ("<base href=\"http://ant.apache.org/ivy/history/latest-milestone/resolver/\">\n");
  printf ("<link rel=\"stylesheet\" type=\"text/css\" href=\"http://ant.apache.org/ivy/style/style.css\">\n");

  printf ("</head>\n");
  printf ("<body id=\"body\">\n")
  printf ("<div>\n")
  printf ("<h1>Packager Resolver</h1>\n")
}

{
  if ( $0 ~ /^Index: / ) {
    if ( $0 ~ /^Index: doc\/resolver\/packager.html$/ )
      GOTFILE = 1
    else
      GOTFILE = 0
  }
  if (GOTFILE) {
    if ( $0 ~ /^\+/ ) {
      gsub(/^\+/, "")
      if ( $0 ~ /<\/textarea/ )
        PRINTING = 0
      if ( $0 ~ /^<\/code/ ) {
        CODE = 0
        gsub(/^<\/code/, "</pre")
      }
      if ( $0 ~ /^<code/ )
        gsub(/^<code/, "<pre")
      if (PRINTING) {
        if (CODE) {
          gsub(/&/, "\\&amp;")
          gsub(/</, "\\&lt;")
          gsub(/>/, "\\&gt;")
        }
        printf "%s\n", $0
      }
      if ( $0 ~ /<textarea/ )
        PRINTING = 1
      if ( $0 ~ /^<pre/ )
        CODE = 1
    }
  }
}

END {
  printf ("</div>\n")
  printf ("</body>\n");
  printf ("</html>\n")
}

