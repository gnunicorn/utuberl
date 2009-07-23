
-module(utuberl).

%% public api
-export([parse_youtube_video/1]).

%% test api
-export([test_video_parsing/0]).

-record(utube_video,{
  title,
  url,
  video_url,
  embed_code
}).

parse_youtube_video(Body) ->
  Tree = mochiweb_html:parse(Body),
  [Url|_] = mochiweb_xpath:execute(".//input[@id=\"watch-url-field\"]/@value", Tree),
  [Embed|_] = mochiweb_xpath:execute(".//input[@id=\"embed_code\"]/@value", Tree),
  [{_H1, _Attrs, [Title| _Others]} |_] = mochiweb_xpath:execute(".//div[@id=\"watch-vid-title\"]/h1", Tree),
  {ok, #utube_video{title=Title,url=Url,embed_code=Embed} }.

%% Tests
test_video_parsing() ->
  {ok, Data} = file:read_file(filename:absname_join("data", "watch_choose_trainspotting")),
  Expected = #utube_video{title="Choose (Trainspotting)",
      embed_code="<object width=\"425\" height=\"344\"><param name=\"movie\" value=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"425\" height=\"344\"></embed></object>",
      video_url="http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1"
      },
  {ok, Expected} = parse_youtube_video(Data),
  ok.
