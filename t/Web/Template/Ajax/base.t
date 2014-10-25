use strict;
use warnings;
use App::Mobirc::Web::View;
use Test::More tests => 1;
use HTTP::MobileAgent;
use Text::Diff;
use App::Mobirc;

local $App::Mobirc::VERSION = 0.01;
my $got = App::Mobirc::Web::View->show(
    'ajax/base' => (
        user_agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
        docroot    => '/'
    )
);

my $expected = <<'...';
<?xml version="1" encoding="UTF-8"?>

<html lang="ja" xml:lang="ja" xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta http-equiv="Cache-Control" content="max-age=0" />
  <meta name="robots" content="noindex, nofollow" />
  <link rel="stylesheet" href="/static/pc.css" type="text/css" />
  <link rel="stylesheet" href="/static/mobirc.css" type="text/css" />
  <script src="/static/jquery.js"></script>
  <script src="/static/mobirc.js"></script>
  <title>mobirc</title>
 </head>
 <body>
  <div id="body">
   <div id="main">
    <div id="menu"></div>
    <div id="contents"></div>
   </div>
   <div id="footer">
    <form onsubmit="send_message&#40;&#41;;return false">
     <input type="text" id="msg" name="msg" size="30" />
     <input type="button" value="send" onclick="send_message&#40;&#41;;" />
    </form>
    <div>
     <span>mobirc -</span>
     <span class="version">0.01</span>
    </div>
   </div>
  </div>
  <script lang="javascript">docroot = '/';</script>
 </body>
</html>
...
$expected =~ s/\n$//;

ok !diff(\$got, \$expected), diff(\$got, \$expected, { STYLE => "Context" });

