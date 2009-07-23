
-module(utuberl).

%% public api
-export([parse_youtube_video/1]).

%% test api
-export([test_video_parsing/0]).

-record(utube_video,{
  title,
  video_id,
  url,
  video_url,
  tags=[],
  embed_code
}).

parse_youtube_video(Body) ->
  Tree = mochiweb_html:parse(Body),
  %% alright. let's find stuff. first match is enough
  %% FIXME: actually if the first one was found the execution could stop as we
  %%        are happy already but AFAIK that ain't supported by mochiweb_xpath
  %%        yet
  [Title| _] = mochiweb_xpath:execute(".//div[@id=\"watch-vid-title\"]/h1/text()", Tree),
  [Url|_] = mochiweb_xpath:execute(".//input[@id=\"watch-url-field\"]/@value", Tree),
  [Embed|_] = mochiweb_xpath:execute(".//input[@id=\"embed_code\"]/@value", Tree),
  %% there we actually want the full list
  Tags = mochiweb_xpath:execute(".//div[@id=\"watch-video-tags\"]/a/text()", Tree),
  %% no we do something intresting: we know the code inside of "Embed" is html
  %% again so we parse it and use xpath once more to find the URL
  [Video_url| _] = mochiweb_xpath:execute(".//param[@name=\"movie\"]/@value", mochiweb_html:parse(Embed)),
  %% and then find the totally correct video id inside of that URL
  %% FIXME: is this really a value of interest or is this useless and the code
  %%        with it?
  V_url = binary_to_list(Video_url),
  Video_id = string:sub_string(V_url, string:rstr(V_url, "/") + 1),
  {ok, #utube_video{title=Title,url=Url,tags=Tags,
	  embed_code=Embed,video_url=Video_url,video_id=Video_id} }.

%% Tests
test_video_parsing() ->
  {ok, Data} = file:read_file(filename:absname_join("data", "watch_choose_trainspotting")),
  Expected = #utube_video{title="Choose (Trainspotting)",
      embed_code="<object width=\"425\" height=\"344\"><param name=\"movie\" value=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"425\" height=\"344\"></embed></object>",
      video_url="http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1"
      },
  {ok, Expected} = parse_youtube_video(Data),
  ok.
